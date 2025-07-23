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
--  EXEC    [AVL].[Infra_GetMasterHierarchyValues]
-- ============================================================================
CREATE PROCEDURE [AVL].[Infra_GetMasterHierarchyValues]

AS
BEGIN

	BEGIN TRY

		SELECT HierarchyOneMasterID,HierarchyName FROM AVL.InfraHierarchyOneMaster WHERE IsDeleted=0

		SELECT HierarchyTwoMasterID,HierarchyName FROM AVL.InfraHierarchyTwoMaster WHERE IsDeleted=0

		SELECT HierarchyThreeMasterID,HierarchyName FROM AVL.InfraHierarchyThreeMaster WHERE IsDeleted=0

		SELECT HierarchyFourMasterID,HierarchyName FROM AVL.InfraHierarchyFourMaster WHERE IsDeleted=0

		SELECT HierarchyFiveMasterID,HierarchyName  FROM AVL.InfraHierarchyFiveMaster WHERE IsDeleted=0

		SELECT HierarchySixMasterID,HierarchyName  FROM AVL.InfraHierarchySixMaster WHERE IsDeleted=0

	END TRY  
	BEGIN CATCH  
			DECLARE @ErrorMessage VARCHAR(MAX);
			SELECT @ErrorMessage = ERROR_MESSAGE()
			EXEC AVL_InsertError '[AVL].[Infra_GetMasterHierarchyValues]', @ErrorMessage, 0,0
	END CATCH  
END
