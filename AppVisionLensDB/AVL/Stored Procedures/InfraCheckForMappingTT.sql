/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE proc [AVL].[InfraCheckForMappingTT] --'52,50','1,2',7097
@TechnologyTowerValues nvarchar(max),
@ServiceLevelValues nvarchar(max),
@CustomerID BIGINT,
@chkmap bit
AS
BEGIN
select * INTO #TechnologyTowerValues from dbo.Split(@TechnologyTowerValues,',')
select * INTO #ServiceLineValues from dbo.Split(@ServiceLevelValues,',')
select distinct TMT.TechnologyTowerID INTO #ValidTmp
 from AVL.InfraTaskMappingTransaction TMT 
	join AVL.InfraHierarchyTwoTransaction H2T on H2T.CustomerID=TMT.CustomerID and H2T.HierarchyTwoTransactionID=TMT.TechnologyTowerID 
	and TMT.IsDeleted=0
	join #TechnologyTowerValues TTV on TTV.Item=TMT.TechnologyTowerID
	
	JOIN AVL.MAS_ServiceLevel SLM on SLM.ServiceLevelID=TMT.SupportLevelID and SLM.IsDeleted=0
	JOIN AVL.InfraTaskTransaction TT on TT.InfraTransactionTaskID=TMT.InfraTransactionTaskID and TT.CustomerID=TMT.CustomerID
	where H2T.CustomerID=@CustomerID and H2T.IsDeleted=0
	and tmt.IsEnabled=1
	and NOT EXISTS(SELECT * from  #ServiceLineValues SLV WHERE SLV.Item=TMT.SupportLevelID )

	IF exists(SELECT TechnologyTowerID FROM #ValidTmp )
	BEGIN
	SELECT TTV.Item,CASE WHEN TMP.TechnologyTowerID IS NULL THEN 0 ELSE 1 END AS 'Valid'
	INTO #tmpcheck
	
	 from  #TechnologyTowerValues TTV LEFT JOIN  #ValidTmp TMP ON TTV.Item=TMP.TechnologyTowerID

SELECT case when count(Item)>0 THEN 0 ELSE 1 end as Valid   from #tmpcheck where Valid=0
END
ELSE
BEGIN

SELECT @chkmap as Valid

END

END
