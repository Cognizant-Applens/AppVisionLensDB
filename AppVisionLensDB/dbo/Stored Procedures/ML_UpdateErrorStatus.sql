/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================ 
-- Author:           Devika 
-- Create date:      11 FEB 2018 
-- Description:      SP for Initial Learning 
-- Test:            [dbo].[ML_UpdateErrorStatus] 
-- ============================================================================ 
CREATE PROCEDURE [dbo].[ML_UpdateErrorStatus] @ProjectID INT, 
                                             @MLJobId   NVARCHAR(MAX), 
                                             @errorData NVARCHAR(MAX), 
                                             @JobStatus INT,
											 @SupportTypeID INT
AS 
  BEGIN 
      BEGIN TRY 
          BEGIN TRAN 

		  IF(@SupportTypeID=1)
		  BEGIN
          IF @JobStatus = 2 
            BEGIN 
                UPDATE AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
                SET    MLSamplingStatus = 'KILLED', 
                       IsDARTProcessed = 'Y', 
                       JobMessage = @errorData 
                WHERE  ProjectID = @ProjectID 
                       AND JobIdFromML = @MLJobId 

                UPDATE AVL.ML_PRJ_INITIALLEARNINGSTATE 
                SET    IsMLSentOrReceived = 'Failed' 
                WHERE  ProjectID = @ProjectID 
                       AND IsDeleted = 0 
            END 
          ELSE 
            BEGIN 
                UPDATE AVL.ML_TRN_MLSAMPLINGJOBSTATUS 
                SET    MLSamplingStatus = 'SUCCESS', 
                       ModifiedOn = GETDATE(), 
                       JobMessage = @errorData 
                WHERE  ProjectID = @ProjectID 
                       AND JobIdFromML = @MLJobId 
            END 
			END
ELSE
BEGIN
          IF @JobStatus = 2 
            BEGIN 
                UPDATE AVL.ML_TRN_MLSamplingJobStatusInfra 
                SET    MLSamplingStatus = 'KILLED', 
                       IsDARTProcessed = 'Y', 
                       JobMessage = @errorData 
                WHERE  ProjectID = @ProjectID 
                       AND JobIdFromML = @MLJobId 

                UPDATE AVL.ML_PRJ_InitialLearningStateInfra 
                SET    IsMLSentOrReceived = 'Failed' 
                WHERE  ProjectID = @ProjectID 
                       AND IsDeleted = 0 
            END 
          ELSE 
            BEGIN 
                UPDATE AVL.ML_TRN_MLSamplingJobStatusInfra 
                SET    MLSamplingStatus = 'SUCCESS', 
                       ModifiedDate = GETDATE(), 
                       JobMessage = @errorData 
                WHERE  ProjectID = @ProjectID 
                       AND JobIdFromML = @MLJobId 
            END 
			END

          COMMIT TRAN 
      END TRY 

      BEGIN CATCH 
          DECLARE @ErrorMessage VARCHAR(MAX); 

          SELECT @ErrorMessage = ERROR_MESSAGE() 

          ROLLBACK TRAN 

          --INSERT Error     
          EXEC AVL_INSERTERROR 
            '[dbo].[ML_UpdateErrorStatus] ', 
            @ErrorMessage, 
            @ProjectID, 
            0 
      END CATCH 
  END
