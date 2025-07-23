/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ML].[InsertMLJobId] (@ID BIGINT, 
                                     @InitialLearningID NVARCHAR(50), 
                                     @MLJobId           NVARCHAR(500) = null, 
                                     @JobType           NVARCHAR(10), 
                                     @JobMessage        NVARCHAR(MAX), 
                                     @UserID            NVARCHAR(20),                                      
									 @MLJobState BIT = 0) 
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 
          
			IF @MLJobState = 0
			BEGIN
			INSERT INTO ML.TRN_MLSamplingJobStatus	
                      (ProjectID, 
                       InitialLearningID, 
                       JobIdFromML, 
                       [FileName], 
                       DataPath, 
                       DARTJobStatus, 
                       InitiatedBy, 
                       JobMessage, 
                       JobType, 
                       CreatedOn, 
                       CreatedBy, 
                       IsDeleted) 
          VALUES     (@ID, 
                      @initialLearningId, 
                      null, 
                      null, 
                      null, 
                      '', 
                      @UserID, 
                      'Sent', 
                      @JobType, 
                      GETDATE(), 
                      @UserID, 
                      0) 

			END
			ELSE
			BEGIN
				UPDATE IL SET IL.JobIdFromML=@MLJobId
				FROM ML.TRN_MLSamplingJobStatus	IL
				WHERE IL.ProjectID= @ID
				AND IL.InitialLearningID= @InitialLearningID
				AND IL.JobIdFromML IS NULL
			END               

          COMMIT TRAN 

		  SELECT TOP 1 ID FROM ML.TRN_MLSamplingJobStatus 
		  WHERE ProjectID=@ID AND 
		  InitialLearningID= @InitialLearningID AND 
		  JobType = @JobType
		  ORDER BY CreatedOn DESC

      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[ML].[InsertMLJobId] ', 
            @ErrorMessage, 
            @ID, 
            0 
      END CATCH 
  END
