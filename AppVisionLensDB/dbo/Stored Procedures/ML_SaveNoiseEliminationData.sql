/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_SaveNoiseEliminationData] (@ProjectID             NVARCHAR(200), 
                                                @EmployeeID            NVARCHAR(500), 
                                                @lstTicketDescWordlist TVP_MLTICKETDESCWORDLIST READONLY,
                                                @lstOptionalWordList   TVP_MLOPTIONALWORDLIST READONLY,
                                                @Choose                INT) 
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

          -- To save or submit noise elimination data(1-initial save ,2-save,3-submit) 
          IF( @Choose = 1 ) 
            BEGIN 
                --Saved data is stored in [AVL].[ML_TicketDescNoiseWords_Dump]  and [AVL].[ML_OptionalFieldNoiseWords_Dump](optional field is defined) 
                DELETE [AVL].[ML_TicketDescNoiseWords_Dump] 
                WHERE  ProjectID = @ProjectID 

                DELETE [AVL].[ML_OptionalFieldNoiseWords_Dump] 
                WHERE  ProjectID = @ProjectID 

                DELETE [AVL].[ML_TicketDescNoiseWords] 
                WHERE  ProjectID = @ProjectID 

                DELETE [AVL].[ML_OptionalFieldNoiseWords] 
                WHERE  ProjectID = @ProjectID 

                CREATE TABLE #NOISETICKETWORDS 
                  ( 
                     [TicketDesFieldNoiseWord] [NVARCHAR](500) NULL, 
                     [Frequency]               [BIGINT] NULL, 
                     [IsActive]                [BIT] NULL, 
                     [ProjectID]               [BIGINT], 
                     [EmployeeID]              [NVARCHAR](500) 
                  ) 

                INSERT INTO #NOISETICKETWORDS 
                SELECT TicketDesFieldNoiseWord, 
                       frequency, 
                       isactive, 
                       @ProjectID, 
                       @EmployeeID 
                FROM   @lstTicketDescWordlist 

                -- Insertion of Desc noise words to [AVL].[ML_TicketDescNoiseWords_Dump](Isactive=1 by default) 
                INSERT INTO [AVL].[ML_TicketDescNoiseWords_Dump] 
                            (ProjectID, 
                             TicketDescNoiseWord, 
                             Frequency, 
                             IsActive, 
                             CreatedDate, 
                             CreatedBy) 
                SELECT ProjectID, 
                       TicketDesFieldNoiseWord, 
                       Frequency, 
                       IsActive, 
                       Getdate(), 
                       EmployeeID 
                FROM   #NOISETICKETWORDS 

                DECLARE @optionaldatacount INT 

                SET @optionaldatacount=(SELECT COUNT(*) 
                                        FROM   @lstOptionalWordList); 

                --If optional count >0 then it will be inserted 
                IF( @optionaldatacount > 0 ) 
                  BEGIN 
                      CREATE TABLE #NOISEOPTIONALWORDS 
                        ( 
                           [OptionalFieldNoiseWord] [NVARCHAR](500) NULL, 
                           [Frequency]              [BIGINT] NULL, 
                           [IsActive]               [BIT] NULL, 
                           [ProjectID]              [BIGINT], 
                           [EmployeeID]             [NVARCHAR](500) 
                        ) 

                      INSERT INTO #NOISEOPTIONALWORDS 
                      SELECT OptionalFieldNoiseWord, 
                             Frequency, 
                             IsActive, 
                             @ProjectID, 
                             @EmployeeID 
                      FROM   @lstOptionalWordList 

                      INSERT INTO [AVL].[ML_OptionalFieldNoiseWords_Dump] 
                                  (ProjectID, 
                                   OptionalFieldNoiseWord, 
                                   Frequency, 
                                   IsActive, 
                                   CreatedDate, 
                                   CreatedBy) 
                      SELECT ProjectID, 
                             optionalfieldnoiseword, 
                             Frequency, 
                             IsActive, 
                             Getdate(), 
                             EmployeeID 
                      FROM   #NOISEOPTIONALWORDS 

                      DELETE AVL.ML_OptionalFieldNoiseWords_Dump 
                      WHERE  ProjectID = @ProjectID 
                             AND OptionalFieldNoiseWord = '' 
                 
                  END 

				  
                ---Updating IsNoiseEliminationSentorReceived in AVL.ML_PRJ_InitialLearningState as 'Saved' 
                UPDATE AVL.ML_PRJ_InitialLearningState 
                SET    IsNoiseEliminationSentorReceived = 'Saved' 
                WHERE  ProjectID = @ProjectID 
            END 

          IF( @Choose = 2 ) 
            BEGIN 
                -- UI Save Excluded words are updated as IsActive=0 
                UPDATE [AVL].[ML_TicketDescNoiseWords_Dump] 
                SET    IsActive = 1 
                WHERE  ProjectID = @ProjectID 

                CREATE TABLE #UPDATEDNOISETICKETWORDS 
                  ( 
                     [TicketDesFieldNoiseWord] [NVARCHAR](500) NULL, 
                     [frequency]               [BIGINT] NULL, 
                     [isactive]                [BIT] NULL, 
                     [ProjectID]               [BIGINT], 
                     [employeeid]              [NVARCHAR](500) 
                  ) 

                INSERT INTO #UPDATEDNOISETICKETWORDS 
                SELECT TicketDesFieldNoiseWord, 
                       Frequency, 
                       IsActive, 
                       @ProjectID, 
                       @EmployeeID 
                FROM   @lstTicketDescWordlist 

                --Excluded words updated isactive=0 
                UPDATE TDW 
                SET    IsActive = 0, 
                       CreatedDate = GETDATE(), 
                       CreatedBy = @EmployeeID 
                FROM   [AVL].[ML_TicketDescNoiseWords_Dump] TDW 
                       INNER JOIN #UPDATEDNOISETICKETWORDS NT 
                               ON NT.TicketDesFieldNoiseWord = TDW.TicketDescNoiseWord 
                                  AND NT.ProjectID = TDW.ProjectID 
                                  AND NT.Frequency = TDW.Frequency 

                DELETE AVL.[ML_TicketDescNoiseWords_Dump] 
                WHERE  ProjectID = @ProjectID 
                       AND TicketDescNoiseWord = '' 

                DECLARE @Updatedoptionaldatacount INT 

                SET @Updatedoptionaldatacount=(SELECT COUNT(*) 
                                               FROM   @lstOptionalWordList); 

               
                --If updateoptionaldatacount>0 then update in ML_OptionalFieldNoiseWords_Dump will happen 
                IF( @Updatedoptionaldatacount > 0 ) --AND @Optionalfield !=NULL) 
                  BEGIN 
                      UPDATE [AVL].[ML_OptionalFieldNoiseWords_Dump] 
                      SET    IsActive = 1 
                      WHERE  ProjectID = @ProjectID 

                      CREATE TABLE #UPDATEDNOISEOPTIONALWORDS 
                        ( 
                           [OptionalFieldNoiseWord] [NVARCHAR](500) NULL, 
                           [Frequency]              [BIGINT] NULL, 
                           [Isactive]               [BIT] NULL, 
                           [ProjectID]              [BIGINT], 
                           [EmployeeID ]             [NVARCHAR](500) 
                        ) 

                      INSERT INTO #UPDATEDNOISEOPTIONALWORDS 
                      SELECT OptionalFieldNoiseWord, 
                             Frequency, 
                             Isactive, 
                             @ProjectID, 
                             @EmployeeID 
                      FROM   @lstOptionalWordList 

                      -- updating isactive=0 for the excluded words for respective project 
                      UPDATE OFNW 
                      SET    IsActive = 0, 
                             CreatedDate = Getdate(), 
                             CreatedBy = @EmployeeID 
                      FROM   AVL.ML_OptionalFieldNoiseWords_Dump OFNW 
                             INNER JOIN #UPDATEDNOISEOPTIONALWORDS OW 
                                     ON OW.OptionalFieldNoiseWord = OFNW.OptionalFieldNoiseWord
                                        AND OW.ProjectID = OFNW.ProjectID 
                                        AND OW.Frequency = OFNW.Frequency 

                      DELETE AVL.ML_OptionalFieldNoiseWords_Dump 
                      WHERE  ProjectID = @ProjectID 
                             AND OptionalFieldNoiseWord = '' 
                
                  END 

                ---Updating IsNoiseEliminationSentorReceived in AVL.ML_PRJ_InitialLearningState as 'Saved' 
                UPDATE AVL.ML_PRJ_InitialLearningState 
                SET    IsNoiseEliminationSentorReceived = 'Saved' 
                WHERE  ProjectID = @ProjectID 
            END 

          IF( @Choose = 3 ) 
            BEGIN 
                -- transferring the excluded words from [AVL].[ML_TicketDescNoiseWords_Dump] to [AVL].[ML_TicketDescNoiseWords] 
                UPDATE [AVL].[ML_TicketDescNoiseWords_Dump] 
                SET    IsActive = 1 
                WHERE  ProjectID = @ProjectID 

                CREATE TABLE #SUBMITNOISETICKETWORDS 
                  ( 
                     [TicketDesFieldNoiseWord] [NVARCHAR](500) NULL, 
                     [Frequency]               [BIGINT] NULL, 
                     [Isactive]                [BIT] NULL, 
                     [ProjectID]               [BIGINT], 
                     [Employeeid]              [NVARCHAR](500) 
                  ) 

                INSERT INTO #SUBMITNOISETICKETWORDS 
                SELECT TicketDesFieldNoiseWord, 
                       Frequency, 
                       Isactive, 
                       @ProjectID, 
                       @EmployeeID 
                FROM   @lstTicketDescWordlist 

                UPDATE TDW 
                SET    IsActive = 0, 
                       CreatedDate = Getdate(), 
                       CreatedBy = @EmployeeID 
                FROM   [AVL].[ML_TicketDescNoiseWords_Dump] TDW 
                       INNER JOIN #SUBMITNOISETICKETWORDS NT 
                               ON NT.TicketDesFieldNoiseWord = TDW.TicketDescNoiseWord 
                                  AND NT.ProjectID = TDW.ProjectID 
                                  AND NT.Frequency = TDW.Frequency 

                -- deleting noise words in [AVL].[ML_TicketDescNoiseWords] under projectid  
                DELETE AVL.ML_TicketDescNoiseWords 
                WHERE  ProjectID = @ProjectID 

                --inserting excluded words from [AVL].[ML_TicketDescNoiseWords_Dump] to [AVL].[ML_TicketDescNoiseWords](IsActive=0) 
                INSERT INTO [AVL].[ML_TicketDescNoiseWords] 
                            (ProjectID, 
                             TicketDescNoiseWord, 
                             Frequency, 
                             IsActive, 
                             CreatedDate, 
                             Createdby) 
                SELECT ProjectID, 
                       TicketDescNoiseWord, 
                       Frequency, 
                       IsActive, 
                       Getdate(), 
                       @EmployeeId 
                FROM   AVL.ML_TicketDescNoiseWords_Dump 
                WHERE  IsActive = 0 
                       AND ProjectID = @ProjectID 

                DECLARE @Submitoptionaldatacount INT 

                SET @Submitoptionaldatacount=(SELECT COUNT(*) 
                                              FROM   @lstOptionalWordList); 

             
                --Submit optional word count is greater than 0 
                IF( @Submitoptionaldatacount > 0 ) --AND @Optionalfield !=NULL) 
                  BEGIN 
                      UPDATE [AVL].[ML_OptionalFieldNoiseWords_Dump] 
                      SET    IsActive = 1 
                      WHERE  ProjectID = @ProjectID 

                      CREATE TABLE #SUBMITNOISEOPTIONALWORDS 
                        ( 
                           [OptionalFieldNoiseWord] [NVARCHAR](500) NULL, 
                           [Frequency]              [BIGINT] NULL, 
                           [IsActive]               [BIT] NULL, 
                           [ProjectID]              [BIGINT], 
                           [EmployeeID]             [NVARCHAR](500) 
                        ) 

                      INSERT INTO #SUBMITNOISEOPTIONALWORDS 
                      SELECT OptionalFieldNoiseWord, 
                             Frequency, 
                             IsActive, 
                             @ProjectID, 
                             @EmployeeID 
                      FROM   @lstOptionalWordList 

                      --updating in dump table for all excluded words as IsActive=0 
                      UPDATE OFNW 
                      SET    IsActive = 0, 
                             CreatedDate = Getdate(), 
                             CreatedBy = @EmployeeID 
                      FROM   AVL.ML_OptionalFieldNoiseWords_Dump OFNW 
                             INNER JOIN #SUBMITNOISEOPTIONALWORDS OW 
                                     ON OW.OptionalFieldNoiseWord = OFNW.OptionalFieldNoiseWord
                                        AND OW.ProjectID = OFNW.ProjectID 
                                        AND OW.frequency = OFNW.Frequency 

                      DELETE AVL.ML_OptionalFieldNoiseWords_Dump 
                      WHERE  ProjectID = @ProjectID 
                             AND OptionalFieldNoiseWord = '' 

                      DELETE AVL.ML_OptionalFieldNoiseWords 
                      WHERE  ProjectID = @ProjectID 

                      --inserting excluded words to [AVL].[ML_OptionalFieldNoiseWords]  
                      INSERT INTO [AVL].[ML_OptionalFieldNoiseWords] 
                                  (ProjectID, 
                                   OptionalFieldNoiseWord, 
                                   Frequency, 
                                   IsActive, 
                                   CreatedDate, 
                                   CreatedBy) 
                      SELECT projectid, 
                             optionalfieldnoiseword, 
                             Frequency, 
                             IsActive, 
                             Getdate(), 
                             @EmployeeId 
                      FROM   AVL.ML_OptionalFieldNoiseWords_Dump 
                      WHERE  IsActive = 0 
                             AND ProjectID = @ProjectID 
           
                  END 

                --updating the  IsNoiseEliminationSentorReceived as Received in AVL.ML_PRJ_InitialLearningState 
                UPDATE AVL.ML_PRJ_InitialLearningState 
                SET    IsNoiseEliminationSentorReceived = 'Received', 
                       IsNoiseSkipped = 0 
                WHERE  ProjectID = @ProjectID 

                IF( @Choose = 3 ) 
                  BEGIN 
                      --- for getting the criteria (ml,sampling,noise) 
                      DECLARE @TotalTickets DECIMAL(18, 2); 
                      DECLARE @OptionalFieldID INT; 
                      DECLARE @Optfieldupl NVARCHAR(50); 
                      DECLARE @NoiseSentorReceived NVARCHAR(500); 
                      DECLARE @ValidTDescription DECIMAL(18, 2); 
                      DECLARE @ValidOptional DECIMAL(18, 2); 
                      DECLARE @ValidDebtFields DECIMAL(18, 2); 
                      DECLARE @InitialID BIGINT; 
                      DECLARE @IsRegenerated BIT; 
                      DECLARE @ValidTicketDescPercent DECIMAL(18, 2) 
                      DECLARE @ValidOptionalPercent DECIMAL(18, 2) 
                      DECLARE @ValidTicketDebtFieldsPercent DECIMAL(18, 2) 
                      DECLARE @IsConditionMetForTDesc NVARCHAR(10); 
                      DECLARE @IsConditionMetForOptional NVARCHAR(10); 
                      DECLARE @IsConditionMetForDebtFields NVARCHAR(10); 
                      DECLARE @IsAutoClassified NVARCHAR(10); 

                      SET @InitialID=(SELECT TOP 1 Isnull(ID, 0) 
                                      FROM   AVL.ML_PRJ_InitialLearningState 
                                      WHERE  ProjectID = @ProjectID 
                                             AND IsDeleted = 0 
                                      ORDER  BY ID DESC) 
                      SET @IsRegenerated=(SELECT TOP 1 Isnull(IsRegenerated, 0) 
                                          FROM   AVL.ML_PRJ_InitialLearningState 
                                          WHERE  ProjectID = @ProjectID 
                                                 AND IsDeleted = 0 
                                          ORDER  BY ID DESC) 
                      SET @OptionalFieldID=(SELECT OptionalFieldID 
                                            FROM   AVL.ML_MAP_OptionalProjMapping 
                                            WHERE  ProjectID = @ProjectID 
                                                   AND IsActive = 1) 

                      SELECT @Optfieldupl = OptionalFieldupl, 
                             @NoiseSentorReceived = IsNoiseEliminationSentorReceived 
                      FROM   AVL.ML_PRJ_InitialLearningState 
                      WHERE  ProjectID = @ProjectID 
                             AND IsDeleted = 0 

                      IF( @IsRegenerated = 1 ) 
                        BEGIN 
                            SET @TotalTickets=(SELECT COUNT(*) 
                                               FROM   AVL.ML_TRN_TicketValidation(NOLOCK) IT 
                                                      JOIN AVL.ML_TRN_RegeneratedApplicationDetails REG
                                                        ON IT.ProjectID = REG.ProjectID 
                                                           AND IT.ApplicationID = REG.ApplicationID
                                                           AND REG.InitialLearningID = @InitialID
                                               WHERE  IT.ProjectID = @ProjectID); 
                            SET @ValidTDescription=(SELECT COUNT(*) 
                                                    FROM   AVL.ML_TRN_TicketValidation(NOLOCK) IT
                                                           JOIN AVL.ML_TRN_RegeneratedApplicationDetails REG
                                                             ON IT.ProjectID = REG.ProjectID 
                                                                AND IT.ApplicationID = REG.ApplicationID
                                                                AND REG.InitialLearningID = @InitialID
                                                    WHERE  IT.ProjectID = @ProjectID 
                                                           AND TicketDescription IS NOT NULL 
                                                           AND TicketDescription <> '' 
                                                           AND IT.IsDeleted = 0 
                                                           AND REG.IsDeleted = 0); 
                            SET @ValidOptional=(SELECT COUNT(*) 
                                                FROM   AVL.ML_TRN_TicketValidation(NOLOCK) IT 
                                                       JOIN AVL.ML_TRN_RegeneratedApplicationDetails REG
                                                         ON IT.ProjectID = REG.ProjectID 
                                                            AND IT.ApplicationID = REG.ApplicationID
                                                            AND REG.InitialLearningID = @InitialID
                                                WHERE  IT.ProjectID = @ProjectID 
                                                       AND OptionalFieldProj IS NOT NULL 
                                                       AND OptionalFieldProj <> '' 
                                                       AND IT.IsDeleted = 0 
                                                       AND REG.IsDeleted = 0); 
                            SET @ValidDebtFields=(SELECT COUNT(*) 
                                                  FROM   AVL.ML_TRN_TicketValidation(NOLOCK) IT
                                                         JOIN AVL.ML_TRN_RegeneratedApplicationDetails REG
                                                           ON IT.ProjectID = REG.ProjectID 
                                                              AND IT.ApplicationID = REG.ApplicationID
                                                              AND REG.InitialLearningID = @InitialID
                                                  WHERE  IT.ProjectID = @ProjectID 
                                                         AND REG.IsDeleted = 0 
                                                         AND IT.IsDeleted = 0 
                                                         AND DebtClassificationID IS NOT NULL 
                                                         AND AvoidableFlagID IS NOT NULL 
                                                         AND CauseCodeID IS NOT NULL 
                                                         AND ResolutionCodeID IS NOT NULL 
                                                         AND ResidualDebtID IS NOT NULL) 
                        END 
                      ELSE 
                        BEGIN 
                            SET @TotalTickets=(SELECT COUNT(*) 
                                               FROM   AVL.ML_TRN_TicketValidation(NOLOCK) 
                                               WHERE  ProjectID = @ProjectID); 
                            SET @ValidTDescription=(SELECT COUNT(*) 
                                                    FROM   AVL.ML_TRN_TicketValidation(NOLOCK) 
                                                    WHERE  ProjectID = @ProjectID 
                                                           AND TicketDescription IS NOT NULL 
                                                           AND TicketDescription <> ''); 
                            SET @ValidOptional=(SELECT COUNT(*) 
                                                FROM   AVL.ML_TRN_TicketValidation(NOLOCK) 
                                                WHERE  ProjectID = @ProjectID 
                                                       AND OptionalFieldProj IS NOT NULL 
                                                       AND OptionalFieldProj <> '' 
                                                       AND IsDeleted = 0); 
                            SET @ValidDebtFields=(SELECT COUNT(*) 
                                                  FROM   AVL.ML_TRN_TicketValidation(NOLOCK) 
                                                  WHERE  ProjectID = @ProjectID 
                                                         AND DebtClassificationID IS NOT NULL 
                                                         AND AvoidableFlagID IS NOT NULL 
                                                         AND CauseCodeID IS NOT NULL 
                                                         AND ResolutionCodeID IS NOT NULL 
                                                         AND ResidualDebtID IS NOT NULL) 
                    
                        END 

                      SET @ValidTicketDescPercent= ( ( @ValidTDescription / @TotalTickets ) * 100 );
                      SET @ValidOptionalPercent= ( ( @ValidOptional / @TotalTickets ) * 100 ); 
                      SET @ValidTicketDebtFieldsPercent= ( ( @ValidDebtFields / @TotalTickets ) * 100 );
                      SET @IsAutoClassified = (SELECT Isnull(isautoclassified, 'N') AS IsAutoClassified
                                               FROM   [AVL].[mas_projectdebtdetails] 
                                               WHERE  ProjectID = @ProjectID 
                                                      AND isdeleted = 0) 

                      IF @ValidTicketDescPercent >= 80 
                        BEGIN 
                            SET @IsConditionMetForTDesc='Y' 
                        END 
                      ELSE 
                        BEGIN 
                            SET @IsConditionMetForTDesc='N' 
                        END 

                      IF @ValidOptionalPercent >= 80 
                        BEGIN 
                            SET @IsConditionMetForOptional='Y' 
                        END 
                      ELSE 
                        BEGIN 
                            IF( @OptionalFieldId = 4 
                                 OR @OptionalFieldId IS NULL ) 
                              BEGIN 
                                  SET @IsConditionMetForOptional='Y' 
                              END 
                            ELSE 
                              BEGIN 
                                  SET @IsConditionMetForOptional='N' 
                              END 
                        END 

                      IF @ValidTicketDebtFieldsPercent >= 80 
                        BEGIN 
                            SET @IsConditionMetForDebtFields='Y' 
                        END 
                      ELSE 
                        BEGIN 
                            SET @IsConditionMetForDebtFields='N' 
                        END 

                      IF @TotalTickets < 1000 
                        BEGIN 
                            SELECT 'Not Enough' AS CriteriaMet 
                        END 
                      --Block to check whether for sampling or for ticket upload/download or ML 
                      ELSE IF @IsConditionMetForTDesc = 'Y' 
                         AND @IsConditionMetForDebtFields = 'Y' 
                        BEGIN 
                            IF @IsConditionMetForOptional = 'N' 
                               AND ( @Optfieldupl IS NULL 
                                      OR @Optfieldupl = 'M' ) 
                              BEGIN 
                                  SELECT 'OExcel' AS CriteriaMet 
                              END 
                            ELSE 
                              BEGIN 
                                  IF @NoiseSentorReceived IS NULL 
                                      OR @NoiseSentorReceived = 'Sent' 
                                    BEGIN 
                                        SELECT 'Noise' AS CriteriaMet 
                                    END 
                                  ELSE 
                                    BEGIN 
                                        SELECT 'ML' AS CriteriaMet 
                                    END 
                              END 
                        --Direct ML 
                        END 
                      ELSE IF @IsConditionMetForTDesc = 'Y' 
                         AND @IsConditionMetForDebtFields = 'N' 
                        BEGIN 
                            IF @IsConditionMetForOptional = 'N' 
                               AND ( @Optfieldupl IS NULL 
                                      OR @Optfieldupl = 'M' ) 
                              BEGIN 
                                  SELECT 'OExcel' AS CriteriaMet 
                              END 
                            ELSE 
                              BEGIN 
                                  IF @NoiseSentorReceived IS NULL 
                                      OR @NoiseSentorReceived = 'Sent' 
                                    BEGIN 
                                        SELECT 'Noise' AS CriteriaMet 
                                    END 
                                  ELSE 
                                    BEGIN 
                                        SELECT 'Sampling' AS CriteriaMet 
                                    --Sampling 
                                    END 
                              END 
                        --Direct ML 
                        END 
                      ELSE IF @IsAutoClassified = 'N' 
                        BEGIN 
                            SELECT 'N' AS CriteriaMet 
                        END 
                      ELSE 
                        BEGIN 
                            IF @IsConditionMetForTDesc = 'N' 
                               AND @IsConditionMetForOptional = 'N' 
                              BEGIN 
                                  SELECT 'TExcel' AS CriteriaMet 
                              END 
                            ELSE IF @IsConditionMetForTDesc = 'N' 
                              BEGIN 
                                  SELECT 'Excel' AS CriteriaMet 
                              END 
                        --Download/Upload 
                        END 
                  END 
            END 

          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = Error_message() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC Avl_inserterror 
            '[dbo].[ML_SaveNoiseEliminationData]', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
