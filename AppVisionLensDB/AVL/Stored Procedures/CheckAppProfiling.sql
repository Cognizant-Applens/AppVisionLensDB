/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[CheckAppProfiling] 
	
		@CustomerID nvarchar(100)=null,
		@UserID nvarchar(100)=null
AS
BEGIN
BEGIN TRY
DECLARE @ReturnValue int=0;
IF EXISTS(
		SELECT 1 FROM  AVL.BusinessCluster WHERE CustomerID=@CustomerID AND IsDeleted=0)
			BEGIN
			IF EXISTS(SELECT 1 FROM  AVL.BusinessClusterMapping WHERE CustomerID=
					@CustomerID AND IsDeleted=0 AND IsHavingSubBusinesss=0)
					BEGIN
					SET @ReturnValue=1		
					END
			ELSE
					BEGIN
					SET @ReturnValue=2		
						END
			
			END
			ELSE
			BEGIN
			SET @ReturnValue=0		
			END
SELECT @ReturnValue AS 'Status'
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
	DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		
		EXEC AVL_InsertError '[AVL].[CheckAppProfiling]', @ErrorMessage, @UserID, @CustomerID 
END CATCH
END
