/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[APP_INV_GetTreeStructureDetailsByCustomerID] 
	@customerID bigint,
@user nvarchar(50)
AS
BEGIN
BEGIN TRY
		SELECT		
				AL.BusinessClusterMapID,
				AL.BusinessClusterBaseName,
				AL.BusinessClusterID,
				AL.ParentBusinessClusterMapID 
		FROM 
				AVL.BusinessClusterMapping AL
				WITH(NOLOCK) 
				WHERE 
				CustomerID = @customerID
				AND 
				IsDeleted=0
				AND AL.BusinessClusterID
				IN (SELECT B.BusinessClusterID FROM AVL.BusinessCluster B WHERE CustomerID=@customerID AND IsDeleted=0);

		SELECT
				COUNT(*) AS 'Level'
		FROM 
				AVL.BusinessCluster
				WITH(NOLOCK)
				WHERE
				CustomerID=@customerID;

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[APP_INV_GetTreeStructureDetailsByCustomerID]', @ErrorMessage, @user, @customerID 
		
	END CATCH  
	
END
