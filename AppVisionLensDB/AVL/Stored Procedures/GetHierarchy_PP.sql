/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE  [AVL].[GetHierarchy_PP] --14245
@CustomerID int
AS        
BEGIN        
BEGIN TRY
SET NOCOUNT ON;    

DECLARE @AppCount AS INT;
DECLARE @IsCognizant AS BIT;
DECLARE @IsHaving AS BIT;
SET @IsHaving=0;

SET @IsCognizant=(SELECT ISNULL(IsCognizant,0) AS IsCognizant FROM AVL.Customer(NOLOCK) WHERE CustomerID=@CustomerID AND IsDeleted=0)

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
		BusinessClusterID, BusinessClusterName, IsHavingSubBusinesss, @AppCount AS AppCount,@IsCognizant AS IsCognizant into #BusinessCluster
	FROM 
		AVL.BusinessCluster WITH (NOLOCK)
	WHERE 
		CustomerID = @CustomerID
	AND
		IsDeleted=0
	ORDER BY 
		BusinessClusterID

IF((SELECT COUNT(BusinessClusterID) FROM #BusinessCluster)>1)
BEGIN
SELECT 
		BusinessClusterID, BusinessClusterName, IsHavingSubBusinesss, @AppCount AS AppCount,@IsCognizant AS IsCognizant
	FROM #BusinessCluster
END
ELSE
BEGIN
SELECT 
	0 AS BusinessClusterID,'' AS BusinessClusterName,@IsHaving AS IsHavingSubBusinesss, @AppCount AS AppCount,@IsCognizant AS IsCognizant
END

SET NOCOUNT OFF;        
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[GetHierarchy_PP]', @ErrorMessage, 0,@CustomerID
		
	END CATCH  
END
