/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[Infra_GetGridValuesTaskMapping] --7097,'25,20,19,33,24,7,22,1,26,23,21','1,2,3,4'
@CustomerID bigint,
@TechnologyTowerValues varchar(MAX),
@ServiceLevelValues varchar(MAX)
AS
BEGIN
	BEGIN TRY
	select * INTO #TechnologyTowerValues from dbo.Split(@TechnologyTowerValues,',')
	select * INTO #ServiceLineValues from dbo.Split(@ServiceLevelValues,',')

	SELECT HT.HierarchyTwoTransactionID,HT.HierarchyName,HT.CustomerID,HT.IsDeleted INTO #TmpHierarchyTwo from AVL.InfraHierarchyTwoTransaction HT JOIN #TechnologyTowerValues TTV ON TTV.Item=ht.HierarchyTwoTransactionID and HT.IsDeleted=0
	and HT.CustomerID=@CustomerID
	select TMT.InfraTaskID,H2T.HierarchyTwoTransactionID as TechnologyTowerID,H2T.HierarchyName as TechnologyTower,SLM.ServiceLevelID,SLM.ServiceLevelName
	,TT.InfraTransactionTaskID,ISNULL(TT.InfraTaskName,'') AS InfraTaskName ,ISNULL(TMT.IsEnabled,0) AS IsEnabled,ISNULL(TMT.IsMaster,0) AS IsMaster from AVL.InfraTaskMappingTransaction TMT 
	join #ServiceLineValues SLV on SLV.Item=TMT.SupportLevelID
	join #TechnologyTowerValues TTV on TTV.Item=TMT.TechnologyTowerID
	JOIN AVL.MAS_ServiceLevel SLM on SLM.ServiceLevelID=TMT.SupportLevelID and SLM.IsDeleted=0
	 JOIN AVL.InfraTaskTransaction TT on TT.InfraTransactionTaskID=TMT.InfraTransactionTaskID and TT.CustomerID=TMT.CustomerID
	right join #TmpHierarchyTwo H2T on H2T.CustomerID=TMT.CustomerID and H2T.HierarchyTwoTransactionID=TMT.TechnologyTowerID 
	and TMT.IsDeleted=0
	where  H2T.CustomerID=@CustomerID and H2T.IsDeleted=0
	ORDER by H2T.HierarchyName
	END TRY  
	BEGIN CATCH  
			DECLARE @ErrorMessage VARCHAR(MAX);
			SELECT @ErrorMessage = ERROR_MESSAGE()
			EXEC AVL_InsertError '[AVL].[Infra_GetGridValuesTaskMapping]', @ErrorMessage, 0,0
		END CATCH  
END
