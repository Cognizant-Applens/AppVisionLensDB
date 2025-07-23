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
-- Author:    683989 
-- Create date: 15/12/2019
-- Description:   SP for Noice Upload

-- =============================================  
CREATE PROCEDURE [ML].[SaveNoiseUploadTemplateDetails](
	@ProjectID BIGINT, --ProjectID	
	@UserID NVARCHAR(1000),
    @TVP_lstMLNoiseTicketDescription  ML.NoiseTicketDescription READONLY ,
	@TVP_lstMLNoiseResolutionRemarks  ML.NoiseTicketDescription READONLY
)
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN		   
		   BEGIN
		   DECLARE @InitialID BIGINT = 0;
		  SET @InitialID = (SELECT TOP 1 ID FROM ML.ConfigurationProgress WHERE  projectid = @ProjectID   
                  AND IsDeleted = 0 ORDER BY ID DESC)
		     			
   -- UI Save Excluded words are updated as IsActive=0 
				IF EXISTS (SELECT TOP 1 * FROM @TVP_lstMLNoiseTicketDescription )
				BEGIN
                UPDATE ML.TicketDescNoiseWords_Dump
                SET    IsActive = 1 
                WHERE  ProjectID = @ProjectID 
				AND InitialLearningID =@InitialID

                CREATE TABLE #UPDATEDNOISETICKETWORDS 
                  ( 
                     [TicketDesFieldNoiseWord] [NVARCHAR](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, 
                     [frequency]               [BIGINT] NULL,                    
                     [ProjectID]               [BIGINT], 
                     [employeeid]              [NVARCHAR](500) 
                  ) 

                INSERT INTO #UPDATEDNOISETICKETWORDS 
                SELECT Keywords, 
                       Frequency,                      
                       @ProjectID, 
                       @UserID 
                FROM   @TVP_lstMLNoiseTicketDescription 



				----Exclude noise word status update in [ML].[TicketDescNoiseWords] for sbb
				UPDATE TDW 
                SET    IsActive = 1, 
                       CreatedDate = GETDATE(), 
                       CreatedBy = @UserID 
                FROM   [ML].[TicketDescNoiseWords] TDW 
                       LEFT JOIN #UPDATEDNOISETICKETWORDS NT 
                ON NT.TicketDesFieldNoiseWord = TDW.TicketDescNoiseWord 
                       AND NT.ProjectID = TDW.ProjectID 
                       AND NT.Frequency = TDW.Frequency 
					   AND TDW.InitialLearningID = @InitialID
				WHERE TDW.Source ='SBB' AND NT.TicketDesFieldNoiseWord IS NULL


				----Incude noise word status update in [ML].[TicketDescNoiseWords] for sbb
				UPDATE TDW 
                SET    IsActive = 0, 
                       CreatedDate = GETDATE(), 
                       CreatedBy = @UserID 
                FROM   [ML].[TicketDescNoiseWords] TDW 
                       INNER JOIN #UPDATEDNOISETICKETWORDS NT 
                ON NT.TicketDesFieldNoiseWord = TDW.TicketDescNoiseWord 
                       AND NT.ProjectID = TDW.ProjectID 
                       AND NT.Frequency = TDW.Frequency 
					   AND TDW.InitialLearningID = @InitialID
				WHERE TDW.Source ='SBB'
				
				



                --Excluded words updated isactive=0 
                UPDATE TDW 
                SET    IsActive = 0, 
                       CreatedDate = GETDATE(), 
                       CreatedBy = @UserID 
                FROM   ML.TicketDescNoiseWords_Dump TDW 
                       INNER JOIN #UPDATEDNOISETICKETWORDS NT 
                               ON NT.TicketDesFieldNoiseWord = TDW.TicketDescNoiseWord 
                                  AND NT.ProjectID = TDW.ProjectID 
                                  AND NT.Frequency = TDW.Frequency 
								  AND TDW.InitialLearningID = @InitialID

				
				---Insert Noise Ticket Description Dump Details 
				INSERT INTO ML.TicketDescNoiseWords_Dump
				(	ProjectID,
					InitialLearningID,
					TicketDescNoiseWord,
					Frequency,
					IsActive,
					CreatedDate,
					CreatedBy)
				SELECT				
					NT.ProjectID,
					@InitialID,
					NT.TicketDesFieldNoiseWord,
					NT.Frequency,
					0,
					GETDATE(),
					@UserID							
				FROM #UPDATEDNOISETICKETWORDS NT
				LEFT JOIN ML.TicketDescNoiseWords_Dump TDW 
					ON NT.TicketDesFieldNoiseWord = TDW.TicketDescNoiseWord 
					AND TDW.ProjectID=NT.ProjectID 
					AND TDW.InitialLearningID = @InitialID
				LEFT JOIN [ML].[TicketDescNoiseWords] TD 
					ON NT.TicketDesFieldNoiseWord = TD.TicketDescNoiseWord 
					AND TD.ProjectID=NT.ProjectID 
					AND TD.InitialLearningID = @InitialID
					AND TD.Source = 'SBB'
				WHERE TDW.TicketDescNoiseWord IS NULL AND TD.TicketDescNoiseWord IS NULL
					


				DELETE ML.TicketDescNoiseWords_Dump
					WHERE  ProjectID = @ProjectID 
							AND InitialLearningID = @InitialID
						   AND TicketDescNoiseWord = ''
				END
			IF EXISTS (SELECT TOP 1 * FROM @TVP_lstMLNoiseResolutionRemarks )
				BEGIN
				UPDATE ML.OptionalFieldNoiseWords_Dump
									SET    IsActive = 1 
									WHERE  ProjectID = @ProjectID 
									AND InitialLearningID = @InitialID

                    CREATE TABLE #UPDATEDNOISEOPTIONALWORDS 
                    ( 
                        [OptionalFieldNoiseWord] [NVARCHAR](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, 
                        [Frequency]              [BIGINT] NULL,                         
                        [ProjectID]              [BIGINT], 
                        [EmployeeID ]             [NVARCHAR](500) 
                    ) 

                    INSERT INTO #UPDATEDNOISEOPTIONALWORDS 
                    SELECT Keywords, 
                            Frequency,                           
                            @ProjectID, 
                            @UserID 
                    FROM   @TVP_lstMLNoiseResolutionRemarks 


					----Exclude noise word status update in ML.OptionalFieldNoiseWords for sbb
				UPDATE OFNW 
                SET    IsActive = 1, 
                       CreatedDate = GETDATE(), 
                       CreatedBy = @UserID 
                FROM   ML.OptionalFieldNoiseWords OFNW 
                LEFT JOIN #UPDATEDNOISEOPTIONALWORDS OW 
                                    ON OW.OptionalFieldNoiseWord = OFNW.OptionalFieldNoiseWord
                                    AND OW.ProjectID = OFNW.ProjectID 
                                    AND OW.Frequency = OFNW.Frequency
									AND OFNW.InitialLearningID = @InitialID
				WHERE OFNW.Source ='SBB' AND OW.OptionalFieldNoiseWord IS NULL


				----Incude noise word status update in ML.OptionalFieldNoiseWords for sbb

				 UPDATE OFNW 
                    SET    IsActive = 0, 
                            CreatedDate = Getdate(), 
                            CreatedBy = @UserID 
                    FROM   ML.OptionalFieldNoiseWords OFNW 
                            INNER JOIN #UPDATEDNOISEOPTIONALWORDS OW 
                                    ON OW.OptionalFieldNoiseWord = OFNW.OptionalFieldNoiseWord
                                    AND OW.ProjectID = OFNW.ProjectID 
                                    AND OW.Frequency = OFNW.Frequency
									AND OFNW.InitialLearningID = @InitialID
					WHERE OFNW.Source ='SBB'
				


                    --updating isactive=0 for the excluded words for respective project 
					--either updating in dump table for all excluded words as IsActive=0 
                    UPDATE OFNW 
                    SET    OFNW.IsActive = 0, 
                            OFNW.CreatedDate = Getdate(), 
                            OFNW.CreatedBy = @UserID 
                    FROM   ML.OptionalFieldNoiseWords_Dump OFNW 
                            INNER JOIN #UPDATEDNOISEOPTIONALWORDS OW 
                                    ON OW.OptionalFieldNoiseWord = OFNW.OptionalFieldNoiseWord
                                    AND OW.ProjectID = OFNW.ProjectID 
                                    AND OW.Frequency = OFNW.Frequency 
									AND OFNW.InitialLearningID = @InitialID

				---Insert Resolution Remark	Dump details
				INSERT INTO ML.OptionalFieldNoiseWords_Dump
				(	ProjectID,
					InitialLearningID,
					OptionalFieldNoiseWord,
					Frequency,
					IsActive,
					CreatedDate,
					CreatedBy)
				SELECT				
					OW.ProjectID,
					@InitialID,
					OW.OptionalFieldNoiseWord,
					OW.Frequency,
					0,
					GETDATE(),
					@UserID							
				FROM #UPDATEDNOISEOPTIONALWORDS  OW
				LEFT JOIN ML.OptionalFieldNoiseWords_Dump OFNW
					 ON OW.OptionalFieldNoiseWord = OFNW.OptionalFieldNoiseWord
					 AND OFNW.ProjectID=OW.ProjectID 
					 AND OFNW.InitialLearningID = @InitialID
			   LEFT JOIN ML.OptionalFieldNoiseWords OFN 
					ON OFN.OptionalFieldNoiseWord = OW.OptionalFieldNoiseWord 
					AND OFN.ProjectID=OW.ProjectID 
					AND OFN.InitialLearningID = @InitialID
					AND OFN.Source = 'SBB'
			  WHERE OFNW.OptionalFieldNoiseWord IS NULL AND OFN.OptionalFieldNoiseWord IS NULL 
					 
              			

                    DELETE ML.OptionalFieldNoiseWords_Dump
                    WHERE  ProjectID = @ProjectID 
							AND InitialLearningID = @InitialID
                            AND OptionalFieldNoiseWord = '' 
							
			END	
		 END
	   COMMIT TRAN 
  END TRY
	BEGIN CATCH
       
	   
		DECLARE @ErrorMessage VARCHAR(MAX); 
          DECLARE @ErrorSeverity INT; 
          DECLARE @ErrorState INT; 

          SELECT @ErrorMessage = Error_message() 

          SELECT @ErrorSeverity = Error_severity() 

          SELECT @ErrorState = Error_state() 

          SELECT @ErrorMessage = Error_message() 

         ROLLBACK TRAN 

          --INSERT Error     
          EXEC Avl_inserterror 
            '[ML].[SaveNoiceUploadTemplateDetails]', 
            @ErrorMessage, 
            @ProjectID, 
            0 

			 
      END CATCH 

END
