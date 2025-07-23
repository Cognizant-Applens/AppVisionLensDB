/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[ML_Audit_InsertTicketMasterAuditLog]
@AuditDetails [dbo].[TVP_TicketMasterAuditLog] READONLY
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
BEGIN TRAN

INSERT INTO AVL.Audit_PRJ_TicketMasterAuditLog
(ProjectID,TicketID,FieldName,FromValue,ToValue,Action,ModifiedBy,ModifiedTimeStamp)
SELECT  ProjectID,TicketID,FieldName,FromValue,ToValue,Action,ModifiedBy,ModifiedTimeStamp
FROM @AuditDetails
COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[ML_Audit_InsertTicketMasterAuditLog] ', @ErrorMessage, 0,0
		
	END CATCH  

END
