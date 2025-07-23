/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_ContinousL_UpdateErrorStatus]



@ProjectID INT,

@MLJobId NVARCHAR(MAX),

@errorData NVARCHAR(MAX),

@JobStatus INT

AS

BEGIN
BEGIN TRY
BEGIN TRAN

IF @JobStatus = 2

	BEGIN

		UPDATE  AVL.CL_ContLearningMLJobStatus

		SET JobMessage=@errorData

		WHERE ProjectID=@ProjectID AND JobIdFromML=@MLJobId

		

		UPDATE  AVL.CL_PRJ_ContLearningState

		SET PresentStatus=5 where ProjectID=@ProjectID and IsDeleted=0

	

		--SELECT * FROM PRJ.Debt_InitialLearningState

		

		

	END



ELSE

	BEGIN

		UPDATE  AVL.CL_ContLearningMLJobStatus

		SET  ModifiedDate=getdate(), JobMessage=@errorData

		WHERE ProjectID=@ProjectID AND JobIdFromML=@MLJobId

	END

	--UPDATE TRN.MLSamplingJobStatus 

	--SET MLSamplingStatus=@errorData

	--WHERE ProjectID=@ProjectID AND  JobIdFromML=@MLJobId

COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError 'dbo.ML_ContinousL_UpdateErrorStatus', @ErrorMessage, 0 ,@ProjectID
		
	END CATCH  

END
