/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_SaveMLStatus]
@MLJobId NVARCHAR(MAX),
@JobStatus NVARCHAR(1000),
@ErrorMessage NVARCHAR(MAX),
@MLOrSampling NVARCHAR(20)
AS
BEGIN
BEGIN TRY
BEGIN TRAN
SELECT ID,ProjectID,InitialLearningID,JobIdFromML,[FileName],DataPath,DARTJobStatus,InitiatedBy,JobMessage,JobType,CreatedOn,CreatedBy,
ModifiedOn,ModifiedBy,IsDARTProcessed,MLSamplingStatus,RetryCount,IsDeleted FROM AVL.ML_TRN_MLSamplingJobStatus


DECLARE @InitialLearningId BIGINT
DECLARE @ProjectID INT
SET @InitialLearningId=(SELECT TOP 1 InitialLearningId FROM AVL.ML_TRN_MLSamplingJobStatus WHERE JobIdFromML=@MLJobId)
SET @ProjectID=(SELECT top 1 projectID FROM AVL.ML_PRJ_InitialLearningState WHERE ID=@InitialLearningId
				ORDER BY ID DESC)
				
INSERT INTO AVL.ML_TRN_MLSamplingJobStatus
(ProjectID,InitialLearningID,JobIdfromML,InitiatedBy,DARTJobStatus,JobMessage,CreatedOn,CreatedBy)
VALUES(@ProjectID,@InitialLearningId,@MLJobId,'Analytics',@JobStatus,@ErrorMessage,GETDATE(),'Analytics')
COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage1 VARCHAR(MAX);

		SELECT @ErrorMessage1 = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ML_SaveMLStatus] ', @ErrorMessage1, 0,0
		
	END CATCH  

END
