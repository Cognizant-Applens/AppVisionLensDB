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
--  EXEC   [AVL].[Infra_GetTransactionHierarchyMapping] 8834
-- ============================================================================
CREATE PROCEDURE [AVL].[Infra_GetTransactionHierarchyMapping]
(
	@CustomerID BIGINT
)
AS
BEGIN
	BEGIN TRY
		SELECT IHT.InfraTransMappingID,IHT.CustomerID,IHT.InfraMasterMappingID,IHT.IsMaster,
		IHT.HierarchyOneTransactionID,IOT.HierarchyName HierarchyOneName,
		IHT.HierarchyTwoTransactionID,ITT.HierarchyName HierarchyTwoName,
		IHT.HierarchyThreeTransactionID,ITHT.HierarchyName HierarchyThreeName,
		IHT.HierarchyFourTransactionID,TFT.HierarchyName HierarchyFourName,
		IHT.HierarchyFiveTransactionID,TFVT.HierarchyName HierarchyFiveName,
		IHT.HierarchySixTransactionID,TST.HierarchyName HierarchySixName,
		ITDT.InfraTowerTransactionID,ITDT.TowerName,ITDT.ModeID,IMM.InfraModeName AS HardwareCategoryName,
		ITHA.Type,
		ITHA.Item,
		ITHA.CopyOrSerialNumber,
		ITHA.ModelNumberHardware,
		ITHA.WarrantyExpiryDate,
		ITHA.SourceSupplier,
		ITHA.License,
		ITHA.SupplyDate,
		ITHA.AcceptedDate,
		ITHA.StatusScheduled,
		ITHA.SLA,
		ITHA.ServicePackAndPatchDetails,
		ITHA.AdminGroups,
		ITHA.UserGroups,
		ITHA.IPAddress,
		ITSA.Name,
		ITSA.ProductName,
		ITSA.[Function],
		ITSA.Owner,
		ITSA.Version,
		ITSA.Contact,
		ITSA.Category AS SoftwareCategory,
		ITSA.ProductionDate,
		ITSA.Hotfix,
		ITSA.ServicePack,
		ITSA.Supplier,
		ITSA.Status,
		ITPA.Location,
		ITPA.NatureOfEmployment
		FROM AVL.InfraHierarchyMappingTransaction(NOLOCK) IHT
		INNER JOIN  AVL.InfraHierarchyOneTransaction(NOLOCK) IOT ON IHT.CustomerID=IOT.CustomerID 
					AND IHT.HierarchyOneTransactionID=IOT.HierarchyOneTransactionID AND IOT.IsDeleted=0
		INNER JOIN AVL.InfraHierarchyTwoTransaction(NOLOCK) ITT ON IHT.CustomerID=ITT.CustomerID 
					AND IHT.HierarchyTwoTransactionID=ITT.HierarchyTwoTransactionID AND ITT.IsDeleted=0
		INNER JOIN AVL.InfraHierarchyThreeTransaction(NOLOCK) ITHT ON IHT.CustomerID=ITHT.CustomerID 
					AND IHT.HierarchyThreeTransactionID=ITHT.HierarchyThreeTransactionID AND ITHT.IsDeleted=0
		LEFT JOIN AVL.InfraHierarchyFourTransaction(NOLOCK) TFT ON IHT.CustomerID=ITHT.CustomerID 
					AND IHT.HierarchyFourTransactionID=TFT.HierarchyFourTransactionID AND TFT.IsDeleted=0
		LEFT JOIN AVL.InfraHierarchyFiveTransaction(NOLOCK) TFVT ON IHT.CustomerID=ITHT.CustomerID 
					AND IHT.HierarchyFiveTransactionID=TFVT.HierarchyFiveTransactionID AND TFVT.IsDeleted=0
		LEFT JOIN AVL.InfraHierarchySixTransaction(NOLOCK) TST ON IHT.CustomerID=ITHT.CustomerID 
					AND IHT.HierarchySixTransactionID=TST.HierarchySixTransactionID AND TST.IsDeleted=0
		INNER JOIN AVL.InfraTowerDetailsTransaction ITDT ON IHT.CustomerID=ITDT.CustomerID AND 
				IHT.InfraTransMappingID=ITDT.InfraTransMappingID 
		INNER JOIN AVL.InfraModeMaster IMM ON ITDT.ModeID=IMM.InfraModeID AND IMM.IsDeleted=0
		LEFT JOIN  AVL.InfraTowerHardwareAttributes(NOLOCK) ITHA ON ITDT.InfraTowerTransactionID=ITHA.InfraTowerTransactionID
		LEFT JOIN AVL.InfraTowerSoftwareAttributes(NOLOCK) ITSA ON ITDT.InfraTowerTransactionID=ITSA.InfraTowerTransactionID
		LEFT JOIN AVL.InfraTowerPhysicalResourceAttributes(NOLOCK) ITPA ON ITDT.InfraTowerTransactionID=ITPA.InfraTowerTransactionID
		WHERE IHT.CustomerID=@CustomerID AND ISNULL(IHT.IsDeleted,0)=0
	END TRY  
	BEGIN CATCH  
			DECLARE @ErrorMessage VARCHAR(MAX);
			SELECT @ErrorMessage = ERROR_MESSAGE()
			EXEC AVL_InsertError '[AVL].[Infra_GetTransactionHierarchyMapping]', @ErrorMessage, 0,0
	END CATCH  
END
