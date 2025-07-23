/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[Infra_GetMasterTechTowerServLev] 
@CustomerID bigint
AS
BEGIN
	BEGIN TRY


		SELECT DISTINCT IT.HierarchyTwoTransactionID as TechnologyTowerID,HierarchyName as TechnologyTower  
		from AVL.InfraHierarchyTwoTransaction IT JOIN AVL.InfraHierarchyMappingTransaction IMT
		ON IT.HierarchyTwoTransactionID=IMT.HierarchyTwoTransactionID AND IT.CustomerID=IMT.CustomerID

		AND IMT.IsDeleted=0 AND IT.IsDeleted=0
		JOIN AVL.InfraTowerDetailsTransaction TD ON TD.InfraTransMappingID=IMT.InfraTransMappingID AND TD.CustomerID=IMT.CustomerID
		AND TD.IsDeleted=0  
		where IT.CustomerID=@CustomerID and IT.IsDeleted=0 
		
        select  ServiceLevelID,ServiceLevelName from AVL.MAS_ServiceLevel  where  IsDeleted=0 
		AND ServiceLevelID<=4
		
	END TRY  
	BEGIN CATCH  
			DECLARE @ErrorMessage VARCHAR(MAX);
			SELECT @ErrorMessage = ERROR_MESSAGE()
			EXEC AVL_InsertError '[AVL].[Infra_GetMasterTechTowerServLev]', @ErrorMessage, 0,0
		END CATCH  
END
