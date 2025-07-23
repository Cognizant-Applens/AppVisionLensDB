/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================------
--	Author: Hemanth Varma CH          
--  Create date:    April 16 2019   
--  EXEC  [AVL].[Infra_GetHierarchyDefinition]
-- ============================================================================
CREATE PROCEDURE [AVL].[Infra_GetHierarchyDefinition]
@CustomerID bigint,
@UserID nvarchar(50) = NULL
AS
BEGIN
	BEGIN TRY
		DECLARE @IsCognizant int = (select IsCognizant from AVL.Customer where CustomerID = @CustomerID)
		IF(@IsCognizant = 1)
		BEGIN
		
			IF NOT EXISTS (select 1 from AVL.InfraClusterDefinition where CustomerID = @CustomerID)
			BEGIN
				EXEC [AVL].[Infra_InsertOrUpdateHhierarchy] 'Service Line','Technology Tower','Technology',NULL,NULL,NULL,@CustomerID,@UserID,1
			END
			IF NOT EXISTS (select 1 from AVL.PRJ_ConfigurationProgress where CustomerID = @CustomerID and ScreenID = 17)
			BEGIN
				EXEC [AVL].[SetInfraprogress] @CustomerID,@UserID,17,25
			END 

		END


		select HierarchyOneDefinition,HierarchyTwoDefinition
		,HierarchyThreeDefinition,HierarchyFourDefinition,
		HierarchyFiveDefinition,HierarchySixDefinition from AVL.InfraClusterDefinition where CustomerID=@CustomerID
		 and IsDeleted=0

		



	END TRY  
	BEGIN CATCH  
			DECLARE @ErrorMessage VARCHAR(MAX);
			SELECT @ErrorMessage = ERROR_MESSAGE()
			EXEC AVL_InsertError '[AVL].[Infra_GetHierarchyDefinition]', @ErrorMessage, 0,0
		END CATCH  
END
