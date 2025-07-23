-- =============================================     
-- Author:    688715     
-- Create date: 14/12/2019     
-- Description:   SP for Initial Learning     
-- [ML].[SaveNoiseEliminationData]      
-- =============================================      
CREATE PROCEDURE [ML].[SaveNoiseEliminationData] (@ID           BIGINT,     
                                                @EmployeeID            NVARCHAR(500),     
                                                @TicketDescriptionNoiseWords Ml.TVP_MLTICKETDESCWORDLIST READONLY,    
                                                @OptionalFieldNoiseWords   ML.TVP_MLOPTIONALWORDLIST READONLY,    
                                                @Choose                SMALLINT,    
            @IsSamplingSkipped  BIT,    
            @InitialLearningId BIGINT)     
AS     
  BEGIN     
      BEGIN TRY     
          BEGIN TRAN     
    DECLARE @InitialidCHECK BIGINT     
          -- To save or submit noise elimination data(1-initial save ,2-save,3-submit)     
          IF( @Choose = 1 )     
            BEGIN                    
    
                CREATE TABLE #NOISETICKETWORDS     
                  (     
                     [TicketDesFieldNoiseWord] [NVARCHAR](500)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,     
                     [Frequency]               [BIGINT] NULL,     
                     [IsActive]                [BIT] NULL,     
                     [ProjectID]               [BIGINT],     
                     [EmployeeID]              [NVARCHAR](500),    
      [InitialLearningID] [BIGINT]    
                  )     
    
                INSERT INTO #NOISETICKETWORDS     
                SELECT TicketDesFieldNoiseWord,     
                       frequency,     
                       isactive,     
                       @ID,     
                       @EmployeeID,    
        @InitialLearningId    
                FROM   @TicketDescriptionNoiseWords     
    
                -- Insertion of Desc noise words to [AVL].[ML_TicketDescNoiseWords_Dump](Isactive=1 by default)     
                INSERT INTO [ML].[TicketDescNoiseWords_Dump]    
                            (ProjectID,     
                             TicketDescNoiseWord,     
                             Frequency,     
                             IsActive,     
                             CreatedDate,     
                             CreatedBy,    
        InitialLearningID)     
                SELECT ProjectID,     
                       TicketDesFieldNoiseWord,     
                       Frequency,     
                       IsActive,     
                       Getdate(),     
                       EmployeeID,    
        InitialLearningID    
                FROM   #NOISETICKETWORDS NW WHERE NOT EXISTS (SELECT TicketDescNoiseWord FROM ML.TicketDescNoiseWords_Dump TDD WHERE    
     TDD.TicketDescNoiseWord = NW.TicketDesFieldNoiseWord AND    
     TDD.ProjectID = NW.ProjectID)    
    
                    
        
    
                DECLARE @optionaldatacount INT     
    
                SET @optionaldatacount=(SELECT COUNT(*)     
                                        FROM   @OptionalFieldNoiseWords);     
    
                --If optional count >0 then it will be inserted     
                IF( @optionaldatacount > 0 )     
                  BEGIN     
                      CREATE TABLE #NOISEOPTIONALWORDS     
                        (     
                           [OptionalFieldNoiseWord] [NVARCHAR](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,     
                           [Frequency]              [BIGINT] NULL,     
                           [IsActive]               [BIT] NULL,     
                           [ProjectID]              [BIGINT],     
                           [EmployeeID]             [NVARCHAR](500),    
         [InitialLearningID]  [BIGINT]    
                        )     
    
                      INSERT INTO #NOISEOPTIONALWORDS     
                      SELECT OptionalFieldNoiseWord,     
 Frequency,     
                             IsActive,     
                             @ID,     
  @EmployeeID,    
        @InitialLearningId    
                      FROM @OptionalFieldNoiseWords     
    
                      INSERT INTO [ML].[OptionalFieldNoiseWords_Dump]    
                                  (ProjectID,     
                                   OptionalFieldNoiseWord,     
                                   Frequency,     
                                   IsActive,     
                                   CreatedDate,     
                                   CreatedBy,    
           InitialLearningID)     
                      SELECT ProjectID,     
                             optionalfieldnoiseword,     
                             Frequency,     
                             IsActive,     
                             Getdate(),     
                             EmployeeID,    
        InitialLearningID    
                      FROM   #NOISEOPTIONALWORDS  WHERE NOT EXISTS (SELECT OptionalFieldNoiseWord FROM ML.OptionalFieldNoiseWords_Dump  WHERE    
     ML.OptionalFieldNoiseWords_Dump.OptionalFieldNoiseWord = #NOISEOPTIONALWORDS.OptionalFieldNoiseWord AND     
     ML.OptionalFieldNoiseWords_Dump.ProjectID = #NOISEOPTIONALWORDS.ProjectID)    
    
                      DELETE ML.OptionalFieldNoiseWords_Dump    
                      WHERE  ProjectID = @ID AND InitialLearningID = @InitialLearningId    
                             AND OptionalFieldNoiseWord = ''     
                     
                  END     
    
          
                ---Updating IsNoiseEliminationSentorReceived in ML.ConfigurationProgress as 'Saved'     
                UPDATE ML.ConfigurationProgress    
                SET    IsNoiseEliminationSentorReceived = 'Saved'     
                WHERE  ProjectID = @ID  and ID = @InitialLearningId    
            END     
          ELSE IF( @Choose = 2 OR @Choose = 3 )     
            BEGIN     
                -- UI Save Excluded words are updated as IsActive=0     
                UPDATE [ML].[TicketDescNoiseWords_Dump]    
                SET    IsActive = 1     
                WHERE  ProjectID = @ID AND InitialLearningID = @InitialLearningId    
    
                CREATE TABLE #UPDATEDNOISETICKETWORDS     
                  (     
                     [TicketDesFieldNoiseWord] [NVARCHAR](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,     
                     [frequency]               [BIGINT] NULL,     
                     [isactive]                [BIT] NULL,     
                     [ProjectID]               [BIGINT],     
                     [employeeid]              [NVARCHAR](500),    
      [InitialLearningID]  [BIGINT]    
                  )     
    
                INSERT INTO #UPDATEDNOISETICKETWORDS     
                SELECT TicketDesFieldNoiseWord,     
                       Frequency,     
                       IsActive,     
                       @ID,     
                       @EmployeeID,    
        @InitialLearningId    
                FROM   @TicketDescriptionNoiseWords     
    
                --Include words updated isactive=0     
                UPDATE TDW     
                SET    IsActive = 0,     
                       CreatedDate = GETDATE(),     
                       CreatedBy = @EmployeeID     
                FROM   [ML].[TicketDescNoiseWords_Dump] TDW     
                       INNER JOIN #UPDATEDNOISETICKETWORDS NT     
                               ON NT.TicketDesFieldNoiseWord = TDW.TicketDescNoiseWord     
                                  AND NT.ProjectID = TDW.ProjectID     
                                  AND NT.Frequency = TDW.Frequency     
          AND NT.InitialLearningID = TDW.InitialLearningID    
    
    
    ----Exclude noise word status update in [ML].[TicketDescNoiseWords] for sbb    
    UPDATE TDW     
                SET    IsActive = 1,     
                       CreatedDate = GETDATE(),     
                       CreatedBy = @EmployeeID     
                FROM   [ML].[TicketDescNoiseWords] TDW     
                       LEFT JOIN #UPDATEDNOISETICKETWORDS NT     
                ON NT.TicketDesFieldNoiseWord = TDW.TicketDescNoiseWord     
                       AND NT.ProjectID = TDW.ProjectID     
                       AND NT.Frequency = TDW.Frequency     
        AND NT.InitialLearningID = TDW.InitialLearningID    
    WHERE TDW.Source ='SBB' AND NT.TicketDesFieldNoiseWord IS NULL    
    
    
    ----Incude noise word status update in [ML].[TicketDescNoiseWords] for sbb    
    UPDATE TDW     
                SET    IsActive = 0,     
                       CreatedDate = GETDATE(),     
                       CreatedBy = @EmployeeID     
                FROM   [ML].[TicketDescNoiseWords] TDW     
                       INNER JOIN #UPDATEDNOISETICKETWORDS NT     
                ON NT.TicketDesFieldNoiseWord = TDW.TicketDescNoiseWord     
                       AND NT.ProjectID = TDW.ProjectID     
                       AND NT.Frequency = TDW.Frequency     
        AND NT.InitialLearningID = TDW.InitialLearningID    
    WHERE TDW.Source ='SBB'    
        
        
    
    IF(@Choose = 2)    
    BEGIN    
    ---Insert Noise Ticket Description Dump Details     
    INSERT INTO [ML].[TicketDescNoiseWords_Dump]    
    ( ProjectID,    
     TicketDescNoiseWord,    
     Frequency,    
     IsActive,    
     CreatedDate,    
     CreatedBy,    
     InitialLearningID)    
    SELECT        
     NT.ProjectID,    
     NT.TicketDesFieldNoiseWord,    
     NT.Frequency,    
     0,    
     GETDATE(),    
     @EmployeeID,    
     @InitialLearningId    
    FROM #UPDATEDNOISETICKETWORDS NT    
    LEFT JOIN [ML].[TicketDescNoiseWords_Dump] TDW     
     ON NT.TicketDesFieldNoiseWord = TDW.TicketDescNoiseWord     
     AND TDW.ProjectID=NT.ProjectID     
     AND NT.InitialLearningID = TDW.InitialLearningID    
    LEFT JOIN [ML].[TicketDescNoiseWords] TD     
     ON NT.TicketDesFieldNoiseWord = TD.TicketDescNoiseWord     
     AND TD.ProjectID=NT.ProjectID     
     AND NT.InitialLearningID = TD.InitialLearningID    
     AND TD.Source = 'SBB'    
    WHERE TDW.TicketDescNoiseWord IS NULL AND TD.TicketDescNoiseWord IS NULL    
    
    DELETE [ML].[TicketDescNoiseWords_Dump]    
     WHERE  ProjectID = @ID AND InitialLearningID = @InitialLearningId    
         AND TicketDescNoiseWord = ''    
    END    
    ELSE IF(@Choose = 3)    
    BEGIN    
         
     --inserting excluded words from [AVL].[ML_TicketDescNoiseWords_Dump] to [AVL].[ML_TicketDescNoiseWords](IsActive=0)     
     INSERT INTO [ML].[TicketDescNoiseWords]     
       (ProjectID,     
        TicketDescNoiseWord,     
        Frequency,     
        IsActive,     
        CreatedDate,     
        Createdby,    
        InitialLearningID)     
     SELECT ProjectID,     
      TicketDescNoiseWord,     
      Frequency,     
      IsActive,     
      Getdate(),     
      @EmployeeId,    
      @InitialLearningId    
     FROM   ML.TicketDescNoiseWords_Dump    
     WHERE  IsActive = 0     
      AND ProjectID = @ID AND InitialLearningID = @InitialLearningId    
    END    
    
                DECLARE @Updatedoptionaldatacount INT     
    
                SET @Updatedoptionaldatacount=(SELECT COUNT(*)     
                                               FROM   @OptionalFieldNoiseWords);     
                   
                --If updateoptionaldatacount>0 then update in ML_OptionalFieldNoiseWords_Dump will happen     
    --either Submit optional word count is greater than 0     
                --IF( @Updatedoptionaldatacount > 0 )    
                --  BEGIN     
                    UPDATE [ML].[OptionalFieldNoiseWords_Dump]    
                    SET    IsActive = 1     
                    WHERE  ProjectID = @ID AND InitialLearningID = @InitialLearningId    
    
                    CREATE TABLE #UPDATEDNOISEOPTIONALWORDS     
                    (     
                        [OptionalFieldNoiseWord] [NVARCHAR](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,     
                        [Frequency]              [BIGINT] NULL,     
                        [Isactive]               [BIT] NULL,     
                        [ProjectID]              [BIGINT],     
                        [EmployeeID ]             [NVARCHAR](500),     
      [InitialLearningID]  [BIGINT]    
                    )     
    
                    INSERT INTO #UPDATEDNOISEOPTIONALWORDS     
                    SELECT OptionalFieldNoiseWord,     
                            Frequency,     
                            Isactive,     
                            @ID,     
            @EmployeeID,    
       @InitialLearningId    
                    FROM   @OptionalFieldNoiseWords     
    
         
    ----Exclude noise word status update in [ML].[TicketDescNoiseWords] for sbb    
    UPDATE OFNW     
                SET    IsActive = 1,     
                       CreatedDate = GETDATE(),     
                       CreatedBy = @EmployeeID     
                FROM   ML.OptionalFieldNoiseWords OFNW     
                LEFT JOIN #UPDATEDNOISEOPTIONALWORDS OW     
                                    ON OW.OptionalFieldNoiseWord = OFNW.OptionalFieldNoiseWord    
                                    AND OW.ProjectID = OFNW.ProjectID     
                                    AND OW.Frequency = OFNW.Frequency    
         AND ow.InitialLearningID = OFNW.InitialLearningID    
    WHERE OFNW.Source ='SBB' AND OW.OptionalFieldNoiseWord IS NULL    
    
    
    ----Incude noise word status update in ML.OptionalFieldNoiseWords for sbb    
    
     UPDATE OFNW     
                    SET    IsActive = 0,     
                            CreatedDate = Getdate(),     
                            CreatedBy = @EmployeeID     
                    FROM   ML.OptionalFieldNoiseWords OFNW     
                            INNER JOIN #UPDATEDNOISEOPTIONALWORDS OW     
                                    ON OW.OptionalFieldNoiseWord = OFNW.OptionalFieldNoiseWord    
                                    AND OW.ProjectID = OFNW.ProjectID     
                                    AND OW.Frequency = OFNW.Frequency    
         AND ow.InitialLearningID = OFNW.InitialLearningID    
     WHERE OFNW.Source ='SBB'    
        
                    --updating isactive=0 for the excluded words for respective project     
     --either updating in dump table for all excluded words as IsActive=0     
                    UPDATE OFNW     
                    SET    IsActive = 0,     
                            CreatedDate = Getdate(),     
                            CreatedBy = @EmployeeID     
                    FROM   ML.OptionalFieldNoiseWords_Dump OFNW     
                            INNER JOIN #UPDATEDNOISEOPTIONALWORDS OW     
                                    ON OW.OptionalFieldNoiseWord = OFNW.OptionalFieldNoiseWord    
                                    AND OW.ProjectID = OFNW.ProjectID     
                                    AND OW.Frequency = OFNW.Frequency    
         AND ow.InitialLearningID = OFNW.InitialLearningID    
             
    
    ---Insert Resolution Remark Dump details    
    INSERT INTO ML.OptionalFieldNoiseWords_Dump    
    ( ProjectID,    
     OptionalFieldNoiseWord,    
     Frequency,    
     IsActive,    
     CreatedDate,    
     CreatedBy,    
     InitialLearningID)    
    SELECT        
     OW.ProjectID,    
     OW.OptionalFieldNoiseWord,    
     OW.Frequency,    
     0,    
     GETDATE(),    
     @EmployeeID,    
     OW.InitialLearningID    
    FROM #UPDATEDNOISEOPTIONALWORDS  OW    
    LEFT JOIN ML.OptionalFieldNoiseWords_Dump OFNW     
      ON OW.OptionalFieldNoiseWord = OFNW.OptionalFieldNoiseWord    
      AND OFNW.ProjectID=OW.ProjectID     
      AND OFNW.InitialLearningID = OW.InitialLearningID    
      LEFT JOIN ML.OptionalFieldNoiseWords OFN     
     ON OFN.OptionalFieldNoiseWord = OW.OptionalFieldNoiseWord     
     AND OFN.ProjectID=OW.ProjectID     
     AND OW.InitialLearningID = OFN.InitialLearningID    
     AND OFN.Source = 'SBB'    
     WHERE OFNW.OptionalFieldNoiseWord IS NULL AND OFN.OptionalFieldNoiseWord IS NULL     
          
        
    
                    DELETE ML.OptionalFieldNoiseWords_Dump     
                    WHERE  ProjectID = @ID     
                            AND OptionalFieldNoiseWord = ''     
       AND InitialLearningID = @InitialLearningId    
         
     IF(@Choose = 3)    
     BEGIN    
      DELETE ML.OptionalFieldNoiseWords    
      WHERE  ProjectID = @ID AND InitialLearningID = @InitialLearningId    
    
      --inserting excluded words to [AVL].[ML_OptionalFieldNoiseWords]      
      INSERT INTO ML.OptionalFieldNoiseWords     
         (ProjectID,     
         OptionalFieldNoiseWord,     
         Frequency,     
         IsActive,     
         CreatedDate,     
         CreatedBy,    
         InitialLearningID)     
      SELECT projectid,     
        optionalfieldnoiseword,     
        Frequency,     
        IsActive,     
        Getdate(),     
        @EmployeeId,    
        InitialLearningID    
      FROM   [ML].[OptionalFieldNoiseWords_Dump]    
      WHERE  IsActive = 0     
        AND ProjectID = @ID AND InitialLearningID = @InitialLearningId    
     END    
                  --END     
    
                ---Updating IsNoiseEliminationSentorReceived in ML.ConfigurationProgress as 'Saved'     
    ---eithrt Updating the  IsNoiseEliminationSentorReceived as Received in ML.ConfigurationProgress    
            UPDATE ML.ConfigurationProgress    
                SET IsNoiseEliminationSentorReceived = (CASE WHEN @Choose = 2 THEN 'Saved' WHEN @Choose = 3 THEN 'Received' END),    
     IsNoiseSkipped = (CASE WHEN @Choose = 2 THEN IsNoiseSkipped WHEN @Choose = 3 THEN 0 END)    
                WHERE  ProjectID = @ID AND ID = @InitialLearningId    
            END     
    ELSE IF(@Choose = 4)    
    BEGIN        
     SET @InitialidCHECK=(SELECT TOP 1 ID     
           FROM   ML.ConfigurationProgress     
           WHERE  ProjectID = @ID     
            AND IsDeleted = 0     
           ORDER  BY ID DESC)     
    
     --updating IsNoiseSkipped as 1 because noise elimination is skipped and IsNoiseEliminationSentorReceived=Received    
     UPDATE ML.ConfigurationProgress    
     SET    IsNoiseEliminationSentorReceived = 'Received',     
      IsNoiseSkipped = 1,           
      ModifiedBy = @EmployeeID,     
      ModifiedDate = GETDATE()     
     WHERE  ProjectID = @ID     
      AND IsDeleted = 0     
      AND ID = @InitialLearningId    
    
     DELETE FROM ML.OptionalFieldNoiseWords    
     WHERE  ProjectID = @ID AND InitialLearningID = @InitialLearningId    
    
     DELETE FROM ML.TicketDescNoiseWords    
     WHERE  ProjectID = @ID AND InitialLearningID = @InitialLearningId    
    END          
        
    UPDATE ML.ConfigurationProgress SET IsSamplingSkipped = @IsSamplingSkipped,    
    ModifiedBy = @EmployeeID,    
    ModifiedDate = GETDATE()    
    WHERE ProjectID = @ID AND IsDeleted = 0 AND ID = @InitialLearningId    
    
          COMMIT TRAN     
      END TRY     
    
      BEGIN CATCH     
          DECLARE @ErrorMessage VARCHAR(MAX);     
    
          SELECT @ErrorMessage = Error_message()     
    
          ROLLBACK TRAN     
    
          --INSERT Error         
          EXEC Avl_inserterror     
            '[ML].[SaveNoiseEliminationData]',     
            @ErrorMessage,     
            @ID,     
            0     
      END CATCH     
  END
