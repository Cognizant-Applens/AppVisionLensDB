/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [dbo].[ML_SaveInitialLearningStateMLSubmit]
(
@ProjectID Nvarchar(50), 
@UserID NVARCHAR(200),
@choice NVARCHAR(10),
@SupportId bigint
)
AS
BEGIN
BEGIN TRY
BEGIN TRAN
if(@SupportId=1)
begin
 UPDATE AVL.ML_PRJ_InitialLearningState SET IsMLSentOrReceived='Sent'
 where ProjectID=@ProjectID AND IsDeleted=0 AND IsSamplingInProgress='Submitted'
 END
 ELSE
  UPDATE AVL.ML_PRJ_InitialLearningStateInfra SET IsMLSentOrReceived='Sent'
 where ProjectID=@ProjectID AND IsDeleted=0 AND IsSamplingInProgress='Submitted'

COMMIT TRAN
 END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ML_SaveInitialLearningStateMLSubmit] ', @ErrorMessage, @ProjectID,0
		
	END CATCH  
END
