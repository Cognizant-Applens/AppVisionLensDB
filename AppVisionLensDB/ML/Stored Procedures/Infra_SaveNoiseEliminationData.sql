/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================= 
-- Author:    835658 
-- Create date: 14/07/2020 
-- Description:   SP for Initial Learning 
-- [ML].[Infra_SaveInfraNoiseEliminationData]  
-- =============================================  
CREATE PROCEDURE [ML].[Infra_SaveNoiseEliminationData] (@ID           BIGINT, 
                                                @EmployeeID            NVARCHAR(500), 
                                                @TicketDescriptionNoiseWords Ml.TVP_MLTICKETDESCWORDLIST READONLY,
                                                @OptionalFieldNoiseWords   ML.TVP_MLOPTIONALWORDLIST READONLY,
                                                @Choose                SMALLINT,
												@IsSamplingSkipped		BIT,
												@InitialLearningId BIGINT) 
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 
		  DECLARE @InitialidCHECK BIGINT 
          -- To save or submit noise elimination data(1-initial save ,2-save,3-submit) 
         
                        --choose1 removed
          IF( @Choose = 2 OR @Choose = 3 ) 
            BEGIN 
                -- UI Save Excluded words are updated as IsActive=0 
                UPDATE [ML].[InfraTicketDescNoiseWords]
                SET    IsActive = 1 
                WHERE  ProjectID = @ID AND InitialLearningID = @InitialLearningId

                CREATE TABLE #UPDATEDNOISETICKETWORDS 
                  ( 
                     [TicketDesFieldNoiseWord] [NVARCHAR](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, 
                     [frequency]               [BIGINT] NULL, 
                     [isactive]                [BIT] NULL, 
                     [ProjectID]               [BIGINT], 
                     [employeeid]              [NVARCHAR](500),
					 [InitialLearningID]		[BIGINT]
                  ) 

                INSERT INTO #UPDATEDNOISETICKETWORDS 
                SELECT TicketDesFieldNoiseWord, 
                       Frequency, 
                       IsActive, 
                       @ID, 
                       @EmployeeID,
					   @InitialLearningId
                FROM   @TicketDescriptionNoiseWords 

                --Excluded words updated isactive=0 
                UPDATE TDW 
                SET    IsActive = 0, 
                       CreatedDate = GETDATE(), 
                       CreatedBy = @EmployeeID 
                FROM   [ML].[InfraTicketDescNoiseWords] TDW 
                       INNER JOIN #UPDATEDNOISETICKETWORDS NT 
                               ON NT.TicketDesFieldNoiseWord = TDW.TicketDescNoiseWord 
                                  AND NT.ProjectID = TDW.ProjectID 
                                  AND NT.Frequency = TDW.Frequency 
								  AND NT.InitialLearningID = TDW.InitialLearningID

				IF(@Choose = 2)
				BEGIN
				---Insert Noise Ticket Description  Details 
				INSERT INTO [ML].[InfraTicketDescNoiseWords]
				(	ProjectID,
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
				LEFT JOIN [ML].[InfraTicketDescNoiseWords] TDW 
					ON NT.TicketDesFieldNoiseWord = TDW.TicketDescNoiseWord 
					AND TDW.ProjectID=NT.ProjectID 
					AND NT.InitialLearningID = TDW.InitialLearningID
					WHERE TDW.TicketDescNoiseWord IS NULL

				DELETE [ML].[InfraTicketDescNoiseWords]
					WHERE  ProjectID = @ID AND InitialLearningID = @InitialLearningId
						   AND TicketDescNoiseWord = ''
				END
				
				--choose 3 removed
                DECLARE @Updatedoptionaldatacount INT 

                SET @Updatedoptionaldatacount=(SELECT COUNT(*) 
                                               FROM   @OptionalFieldNoiseWords); 
               
                --If updateoptionaldatacount>0 then update in ML_OptionalFieldNoiseWords_Dump will happen 
				--either Submit optional word count is greater than 0 
                IF( @Updatedoptionaldatacount > 0 )
                  BEGIN 
                    UPDATE [ML].[InfraOptionalFieldNoiseWords]
                    SET    IsActive = 1 
                    WHERE  ProjectID = @ID AND InitialLearningID = @InitialLearningId

                    CREATE TABLE #UPDATEDNOISEOPTIONALWORDS 
                    ( 
                        [OptionalFieldNoiseWord] [NVARCHAR](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, 
                        [Frequency]              [BIGINT] NULL, 
                        [Isactive]               [BIT] NULL, 
                        [ProjectID]              [BIGINT], 
                        [EmployeeID ]             [NVARCHAR](500), 
						[InitialLearningID]		[BIGINT]
                    ) 

                    INSERT INTO #UPDATEDNOISEOPTIONALWORDS 
                    SELECT OptionalFieldNoiseWord, 
                            Frequency, 
                            Isactive, 
                            @ID, 
                            @EmployeeID,
							@InitialLearningId
                    FROM   @OptionalFieldNoiseWords 

                    --updating isactive=0 for the excluded words for respective project 
					--either updating in dump table for all excluded words as IsActive=0 
                    UPDATE OFNW 
                    SET    IsActive = 0, 
                            CreatedDate = Getdate(), 
                            CreatedBy = @EmployeeID 
                    FROM   ML.InfraOptionalFieldNoiseWords OFNW 
                            INNER JOIN #UPDATEDNOISEOPTIONALWORDS OW 
                                    ON OW.OptionalFieldNoiseWord = OFNW.OptionalFieldNoiseWord
                                    AND OW.ProjectID = OFNW.ProjectID 
                                    AND OW.Frequency = OFNW.Frequency
									AND ow.InitialLearningID = OFNW.InitialLearningID
									
            ---Insert Resolution Remark	 details
				INSERT INTO ML.InfraOptionalFieldNoiseWords
				(	ProjectID,
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
				LEFT JOIN ML.InfraOptionalFieldNoiseWords OFNW 
					 ON OW.OptionalFieldNoiseWord = OFNW.OptionalFieldNoiseWord
					 AND OFNW.ProjectID=OW.ProjectID 
					 AND OFNW.InitialLearningID = OW.InitialLearningID
					 WHERE OFNW.OptionalFieldNoiseWord IS NULL              			

                
				
                    DELETE ML.InfraOptionalFieldNoiseWords 
                    WHERE  ProjectID = @ID 
                            AND OptionalFieldNoiseWord = '' 
							AND InitialLearningID = @InitialLearningId
					
					
                  END 

                ---Updating IsNoiseEliminationSentorReceived in ML.ConfigurationProgress as 'Saved' 
				---eithrt Updating the  IsNoiseEliminationSentorReceived as Received in ML.ConfigurationProgress
            UPDATE ML.InfraConfigurationProgress
                SET IsNoiseEliminationSentorReceived = (CASE WHEN @Choose = 2 THEN 'Saved' WHEN @Choose = 3 THEN 'Received' END),
					IsNoiseSkipped = (CASE WHEN @Choose = 2 THEN IsNoiseSkipped WHEN @Choose = 3 THEN 0 END)
                WHERE  ProjectID = @ID AND ID = @InitialLearningId
            END 
		  ELSE IF(@Choose = 4)
		  BEGIN			 
			  SET @InitialidCHECK=(SELECT TOP 1 ID 
								   FROM   ML.InfraConfigurationProgress 
								   WHERE  ProjectID = @ID 
										  AND IsDeleted = 0 
								   ORDER  BY ID DESC) 

			  --updating IsNoiseSkipped as 1 because noise elimination is skipped and IsNoiseEliminationSentorReceived=Received
			  UPDATE ML.InfraConfigurationProgress
			  SET    IsNoiseEliminationSentorReceived = 'Received', 
					 IsNoiseSkipped = 1, 					 
					 ModifiedBy = @EmployeeID, 
					 ModifiedDate = GETDATE() 
			  WHERE  ProjectID = @ID 
					 AND IsDeleted = 0 
					 AND ID = @InitialLearningId
					 ---doubt--
			  --DELETE FROM ML.InfraOptionalFieldNoiseWords
			  --WHERE  ProjectID = @ID AND InitialLearningID = @InitialLearningId

			  --DELETE FROM ML.InfraTicketDescNoiseWords
			  --WHERE  ProjectID = @ID AND InitialLearningID = @InitialLearningId
		  END      
		  
		  UPDATE ML.InfraConfigurationProgress SET IsSamplingSkipped = @IsSamplingSkipped,
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
            '[ML].[Infra_SaveNoiseEliminationData]', 
            @ErrorMessage, 
            @ID, 
            0 
      END CATCH 
  END
