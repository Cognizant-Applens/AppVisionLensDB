/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE  [AVL].[GetHierarchy] 
@CustomerID int
AS        
BEGIN        
BEGIN TRY
SET NOCOUNT ON;    

DECLARE @AppCount AS INT;

SET @AppCount = 0
	
	IF EXISTS(SELECT
					ApplicationID
				FROM
					AVL.APP_MAS_ApplicationDetails A WITH (NOLOCK)
				INNER JOIN
					AVL.BusinessClusterMapping BCM WITH (NOLOCK) ON BCM.CustomerID = @CustomerID AND A.SubBusinessClusterMapID = BCM.BusinessClusterMapID )
		BEGIN
			SET @AppCount = 1
		END  
SELECT 
		BusinessClusterID, BusinessClusterName, IsHavingSubBusinesss, @AppCount AS AppCount
	FROM 
		AVL.BusinessCluster WITH (NOLOCK)
	WHERE 
		CustomerID = @CustomerID
	AND
		IsDeleted=0
	ORDER BY 
		BusinessClusterID

SET NOCOUNT OFF;        
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetHierarchy]', @ErrorMessage, 0,@CustomerID
		
	END CATCH  
END
