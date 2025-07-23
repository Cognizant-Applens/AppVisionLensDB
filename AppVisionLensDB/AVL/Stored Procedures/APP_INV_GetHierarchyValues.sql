/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[APP_INV_GetHierarchyValues]
@CustomerID bigint,
@UserID nvarchar(300)
AS
BEGIN
BEGIN TRY
SELECT 
				ROW_NUMBER() OVER (Order by BusinessClusterID)  AS 'Level',
					BusinessClusterID,BusinessClusterName
			FROM 
					AVL.BusinessCluster BC 
					WITH(NOLOCK)
			WHERE 
					CustomerID=@CustomerID 
			AND 
					BC.IsDeleted=0 order by BusinessClusterID ;
						END TRY  
/*----------------------------------END TRY--------------------------------*/

	BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		  
		EXEC AVL_InsertError '[AVL].[APP_INV_GetHierarchyValues]', @ErrorMessage, @CustomerID, @UserID 
		
	END CATCH  
END
