/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[APP_INV_DeleteHierarchyTreeNodes] 
@CustomerID bigint,
@EmployeeID nvarchar(100)
AS
BEGIN
BEGIN TRY
BEGIN TRANSACTION

UPDATE 
	AVL.BusinessClusterMapping 
SET
	IsDeleted=1,
	ModifiedBy=@EmployeeID,
	ModifiedDate=getdate()
WHERE
 CustomerID=@CustomerID


IF EXISTS(
			SELECT 
					1 
			FROM 
					AVL.PRJ_ConfigurationProgress 
			WHERE 
					ScreenID=1 AND CustomerID=@CustomerID)
BEGIN
IF NOT EXISTS(SELECT 1 FROM AVL.BusinessClusterMapping where CustomerID=@CustomerID AND IsDeleted=0)
	BEGIN
	UPDATE AVL.PRJ_ConfigurationProgress SET CompletionPercentage=25,
	ModifiedBy=@EmployeeID,
	ModifiedDate=GETDATE()
	WHERE CustomerID=@CustomerID AND ScreenID=1
	END
	END



	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	DROP TABLE TreeNodes
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		
		EXEC AVL_InsertError '[AVL].[APP_INV_DeleteHierarchyTreeNodes]', @ErrorMessage, '0', @CustomerID 
END CATCH
	
END
