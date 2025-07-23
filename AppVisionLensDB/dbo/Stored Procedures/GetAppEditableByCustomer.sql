/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[GetAppEditableByCustomer]
(
@CustomerID int
)
AS 
BEGIN
SET NOCOUNT ON;
BEGIN TRY

select isnull( IsAppEditable,0) from AVL.Customer (NOLOCK)where CustomerID=@CustomerID

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		
		EXEC AVL_InsertError '[dbo].[GetAppEditableByCustomer]', @ErrorMessage, '0', @CustomerID 
END CATCH
SET NOCOUNT OFF;
END
