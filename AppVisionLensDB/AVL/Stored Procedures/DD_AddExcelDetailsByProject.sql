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
-- Author:		Dhivya Bharathi M
-- Create date: February 15
-- Description:	Insert record to Excel tracking table and retrive the last inserted records
--EXEC AVL.DD_AddExcelDetailsByProject '19100','471742','Test EXCEL'
-- =============================================
CREATE PROCEDURE [AVL].[DD_AddExcelDetailsByProject]
	-- Add the parameters for the stored procedure here
	@ProjectID BIGINT,
	@EmployeeID NVARCHAR(50)= NULL,
	@FileName NVARCHAR(MAX)= NULL
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY

	    BEGIN TRANSACTION
	           INSERT INTO AVL.Debt_TRN_DDExcelUploadDetails(ProjectID,UploadedBy,UploadedFileName,IsDeleted,CreatedBy,
			   CreatedOn)
			   SELECT @ProjectID,@EmployeeID,@FileName,0,@EmployeeID,GETDATE()

			   SELECT SCOPE_IDENTITY() AS DDUploadID
	    COMMIT TRANSACTION

	END TRY  

    BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRANSACTION
		EXEC [dbo].AVL_InsertError 'AVL.DD_AddExcelDetailsByProject', @ErrorMessage, 0,@ProjectID
		
	END CATCH  
END
