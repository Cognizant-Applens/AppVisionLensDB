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
-- Create date: 08/04/2021
-- Description:   SP for Initial Learning 
-- [ML].[SaveNoiseWord]  
-- =============================================  
CREATE PROCEDURE [ML].[SaveNoiseWord] (@ESAProjectID          NVARCHAR(100), 
                                                @EmployeeID            NVARCHAR(100), 
                                                @lstNoiseWords NVARCHAR(MAX),                                                
                                                @IsTicketDescription BIT,
												@Source NVARCHAR(50)
										) 
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 
		  SET NOCOUNT ON

		 
		  DECLARE @ProjectID BIGINT
		  DECLARE @InitialLearningID BIGINT

		  --drop table lstnoiseword	 

		 

		 SELECT @ProjectID= ProjectID from avl.mas_ProjectMaster WITH (NOLOCK) WHERE ESAProjectID=@ESAProjectID AND isDeleted=0
		 SELECT @InitialLearningID=max(ID) from ML.ConfigurationProgress WITH (NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0

		 ----Insert ML.ConfigurationProgress when SBB project not in configration table
		 IF(ISNULL(@InitialLearningID,0) = 0)
		 BEGIN

		 INSERT INTO ML.ConfigurationProgress
		 (	 ProjectID
			,FromDate
			,ToDate
			,IsOptionalField
			,DebtAttributeId
			,IsNoiseEliminationSentorReceived
			,IsNoiseSkipped
			,IsSamplingSentOrReceived
			,IsSamplingInProgress
			,IsMLSentOrReceived
			,IsDeleted
			,CreatedBy
			,CreatedDate
			,ModifiedBy
			,ModifiedDate
			,IsTicketDescriptionOpted
			,IsWorkPatternUploadCompleted
			,IsWorkPatternPrereqCompleted
			,IsSamplingSkipped
		)
		values(@ProjectID,CONVERT(DATE,getdate()),CONVERT(DATE,getdate()),0,1,NULL,NULL,NULL,NULL,NULL,0,@EmployeeID,GETDATE(),
		NULL,NULL,1,0,0,1)

		SELECT @InitialLearningID=ID from ML.ConfigurationProgress WITH (NOLOCK) WHERE ProjectID=@ProjectID AND IsDeleted=0

		END

		 CREATE TABLE #tmpNoiseWords
                  ( 
                     [TicketNoiseWord]		   [NVARCHAR](500) NULL, 
                     [Frequency]               [BIGINT] NULL, 
                     [IsActive]                [BIT] NULL, 
                     [ProjectID]               [BIGINT], 
                     [EmployeeID]              [NVARCHAR](100),
					 [InitialLearningID]	   [BIGINT],
					 [Source]				   [NVARCHAR](50)
                  ) 

                INSERT INTO #tmpNoiseWords 
                SELECT value AS NoiseWords, 
                       1, 
                       0, 
                       @ProjectID, 
                       @EmployeeID,
					   @InitialLearningID,
					   @Source
               FROM OPENJSON (@lstNoiseWords)
          
          IF( @IsTicketDescription = 1 AND (ISNULL(@ProjectID,0) <> 0) )
            BEGIN   
			
			
                -- Insertion of Desc noise words to [AVL].[ML_TicketDescNoiseWords_Dump](Isactive=1 by default) 
                INSERT INTO [ML].[TicketDescNoiseWords]
                            (ProjectID, 
                             TicketDescNoiseWord, 
                             Frequency, 
                             IsActive, 
                             CreatedDate, 
                             CreatedBy,
							 InitialLearningID,
							 Source) 
                SELECT ProjectID, 
                       TicketNoiseWord, 
                       Frequency, 
                       IsActive, 
                       Getdate(), 
                       EmployeeID,
					   InitialLearningID,
					   Source
               FROM   #tmpNoiseWords TMP WHERE NOT EXISTS (SELECT TicketDescNoiseWord FROM ML.TicketDescNoiseWords TDN  WHERE
					TDN.TicketDescNoiseWord = TMP.TicketNoiseWord AND
					TDN.ProjectID = TMP.ProjectID and  TDN.isActive=0 )

                             				  
               
            END 
         ELSE IF( @IsTicketDescription = 0  AND (ISNULL(@ProjectID,0) <> 0) )
		 BEGIN
		

					  INSERT INTO [ML].[OptionalFieldNoiseWords]
                                  (ProjectID, 
                                   OptionalFieldNoiseWord, 
                                   Frequency, 
                                   IsActive, 
                                   CreatedDate, 
                                   CreatedBy,
								   InitialLearningID,
								   Source) 
                      SELECT ProjectID, 
                             TicketNoiseWord, 
                             Frequency, 
                             IsActive, 
                             Getdate(), 
                             EmployeeID,
							 InitialLearningID,
							 Source
                      FROM   #tmpNoiseWords tmp  WHERE NOT EXISTS (SELECT OptionalFieldNoiseWord  FROM ML.OptionalFieldNoiseWords OFN WITH (NOLOCK) WHERE
					OFN.OptionalFieldNoiseWord = tmp.TicketNoiseWord AND 
					OFN.ProjectID = tmp.ProjectID AND OFN.isActive = 0)

		 END

          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = Error_message() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC Avl_inserterror 
            '[ML].[SaveNoiseWord]', 
            @ErrorMessage, 
            @EmployeeID, 
            0 
      END CATCH 
  END
