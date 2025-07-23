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
--	Author: Dhivya Bharathi M          
--  Create date:    April 16 2019   
--  EXEC   [AVL].[Infra_GetTransactionHierarchyValues]
-- ============================================================================
CREATE PROCEDURE [AVL].[Infra_GetTransactionHierarchyValues]
(
	@CustomerID BIGINT
)
AS
BEGIN

	BEGIN TRY

		SELECT HierarchyOneTransactionID,HierarchyName FROM AVL.InfraHierarchyOneTransaction(NOLOCK)
		WHERE CustomerID=@CustomerID AND IsDeleted=0

		SELECT HierarchyTwoTransactionID,HierarchyName FROM AVL.InfraHierarchyTwoTransaction(NOLOCK)
		WHERE CustomerID=@CustomerID AND IsDeleted=0

		SELECT HierarchyThreeTransactionID,HierarchyName FROM AVL.InfraHierarchyThreeTransaction(NOLOCK) 
		WHERE CustomerID=@CustomerID AND IsDeleted=0

		SELECT HierarchyFourTransactionID,HierarchyName FROM AVL.InfraHierarchyFourTransaction(NOLOCK) 
		WHERE CustomerID=@CustomerID AND IsDeleted=0

		SELECT HierarchyFiveTransactionID,HierarchyName  FROM AVL.InfraHierarchyFiveTransaction(NOLOCK) 
		WHERE CustomerID=@CustomerID AND IsDeleted=0

		SELECT HierarchySixTransactionID,HierarchyName  FROM AVL.InfraHierarchySixTransaction(NOLOCK) 
		WHERE CustomerID=@CustomerID AND IsDeleted=0

	END TRY  
	BEGIN CATCH  
			DECLARE @ErrorMessage VARCHAR(MAX);
			SELECT @ErrorMessage = ERROR_MESSAGE()
			EXEC AVL_InsertError '[AVL].[Infra_GetTransactionHierarchyValues]', @ErrorMessage, 0,0
	END CATCH  
END
