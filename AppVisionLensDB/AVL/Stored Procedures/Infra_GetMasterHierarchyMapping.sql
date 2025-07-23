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
--  EXEC  [AVL].[Infra_GetMasterHierarchyMapping]
-- ============================================================================
CREATE PROCEDURE [AVL].[Infra_GetMasterHierarchyMapping]
AS
BEGIN
	BEGIN TRY
		SELECT InfraMasterMappingID,
		IHM.HierarchyOneMasterID,IOM.HierarchyName HierarchyOneName,
		IHM.HierarchyTwoMasterID,ITM.HierarchyName HierarchyTwoName,
		IHM.HierarchyThreeMasterID,ITTM.HierarchyName HierarchyThreeName,
		IHM.HierarchyFourMasterID,IFM.HierarchyName HierarchyFourName,
		IHM.HierarchyFiveMasterID,IFVM.HierarchyName HierarchyFiveName,
		IHM.HierarchySixMasterID,ISM.HierarchyName HierarchySixName
		FROM AVL.InfraMasterHierarchyMapping(NOLOCK) IHM
		INNER JOIN AVL.InfraHierarchyOneMaster(NOLOCK) IOM ON IHM.HierarchyOneMasterID=IOM.HierarchyOneMasterID AND IOM.IsDeleted=0
		INNER JOIN AVL.InfraHierarchyTwoMaster(NOLOCK) ITM ON IHM.HierarchyTwoMasterID=ITM.HierarchyTwoMasterID AND ITM.IsDeleted=0
		INNER JOIN AVL.InfraHierarchyThreeMaster(NOLOCK) ITTM ON IHM.HierarchyThreeMasterID=ITTM.HierarchyThreeMasterID AND ITTM.IsDeleted=0
		LEFT JOIN AVL.InfraHierarchyFourMaster(NOLOCK) IFM ON IHM.HierarchyFourMasterID=IFM.HierarchyFourMasterID AND IFM.IsDeleted=0
		LEFT JOIN AVL.InfraHierarchyFiveMaster(NOLOCK) IFVM ON IHM.HierarchyFiveMasterID=IFVM.HierarchyFiveMasterID AND IFVM.IsDeleted=0
		LEFT JOIN AVL.InfraHierarchySixMaster(NOLOCK) ISM ON IHM.HierarchySixMasterID=ISM.HierarchySixMasterID AND ISM.IsDeleted=0
		WHERE IHM.IsDeleted=0

	END TRY  
	BEGIN CATCH  
			DECLARE @ErrorMessage VARCHAR(MAX);
			SELECT @ErrorMessage = ERROR_MESSAGE()
			EXEC AVL_InsertError '[AVL].[Infra_GetMasterHierarchyMapping]', @ErrorMessage, 0,0
		END CATCH  
END
