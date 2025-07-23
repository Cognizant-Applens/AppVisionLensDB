/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROC [AVL].[Infra_GetTowerProjectMappingDetails]
@CustomerID BIGINT,
@ProjectID BIGINT
AS
BEGIN

BEGIN TRY

Declare @totalCount bigint,@mappedTechCount bigint,@accessToPM BIT
SELECT TT.HierarchyTwoTransactionID AS 'TechnologyTower',COUNT(TM.InfraTaskID) as 'Mapping' 
INTO #tmpTTMappingCount

 from AVL.InfraHierarchyTwoTransaction TT 
 JOIN AVL.InfraHierarchyMappingTransaction IMT
		ON TT.HierarchyTwoTransactionID=IMT.HierarchyTwoTransactionID 
		AND TT.CustomerID=IMT.CustomerID

		AND IMT.IsDeleted=0 AND TT.IsDeleted=0
		JOIN AVL.InfraTowerDetailsTransaction TD 
		ON TD.InfraTransMappingID=IMT.InfraTransMappingID 
		AND TD.CustomerID=IMT.CustomerID
		AND TD.IsDeleted=0  
 JOIN AVL.InfraTaskMappingTransaction TM
ON TT.HierarchyTwoTransactionID=TM.TechnologyTowerID AND TT.CustomerID=TM.CustomerID AND TM.IsDeleted=0
AND TT.IsDeleted=0 and TT.CustomerID=@CustomerID and TM.IsEnabled=1
GROUP by TT.HierarchyTwoTransactionID
SET @mappedTechCount=( SELECT COUNT(TechnologyTower) FROM #tmpTTMappingCount )
SELECT @totalCount=COUNT( DISTINCT TT.HierarchyTwoTransactionID) FROM AVL.InfraHierarchyTwoTransaction 
TT 
 JOIN AVL.InfraHierarchyMappingTransaction IMT
		ON TT.HierarchyTwoTransactionID=IMT.HierarchyTwoTransactionID 
		AND TT.CustomerID=IMT.CustomerID

		AND IMT.IsDeleted=0 AND TT.IsDeleted=0
		JOIN AVL.InfraTowerDetailsTransaction TD 
		ON TD.InfraTransMappingID=IMT.InfraTransMappingID 
		AND TD.CustomerID=IMT.CustomerID
		AND TD.IsDeleted=0  

WHERE TT.CustomerID=@CustomerID
AND TT.IsDeleted=0
PRINT @mappedTechCount
PRINT @totalCount
IF @mappedTechCount=@totalCount
BEGIN
SET @accessToPM=1
END
ELSE
BEGIN
SET @accessToPM=0
END




Declare @CountForColumn BIGINT=(select COUNT(*) from (SELECT HierarchyOneDefinition from AVL.InfraClusterDefinition where CustomerID=@CustomerID
 UNION
 SELECT HierarchyTwoDefinition from AVL.InfraClusterDefinition where CustomerID=@CustomerID and IsDeleted=0
 UNION
 SELECT HierarchyThreeDefinition from avl.InfraClusterDefinition where CustomerID=@CustomerID and IsDeleted=0
 UNION
  SELECT HierarchyFourDefinition from avl.InfraClusterDefinition ICT JOIN AVL.Customer
  Cust on Cust.CustomerID=ict.CustomerID and Cust.IsDeleted=0 and Cust.IsCognizant=0
   where cUST.CustomerID=@CustomerID and ICT.IsDeleted=0
  and HierarchyFourDefinition is not NULL and HierarchyFourDefinition<>''
  UNION
  SELECT HierarchyFiveDefinition from AVL.InfraClusterDefinition ICT JOIN AVL.Customer
  Cust on Cust.CustomerID=ict.CustomerID and Cust.IsDeleted=0 and Cust.IsCognizant=0
  
  
   where ICT.CustomerID=@CustomerID and ICT.IsDeleted=0
  and HierarchyFiveDefinition is not NULL and HierarchyFiveDefinition<>''
  UNION
    SELECT HierarchySixDefinition from AVL.InfraClusterDefinition ICT JOIN AVL.Customer
  Cust on Cust.CustomerID=ict.CustomerID and Cust.IsDeleted=0 and Cust.IsCognizant=0
  
  
   where ICT.CustomerID=@CustomerID and ICT.IsDeleted=0
  and HierarchySixDefinition is not NULL and HierarchySixDefinition<>''
  ) as A)
SELECT IMT.HierarchyOneTransactionID,IMT.HierarchyTwoTransactionID,
IMT.HierarchyThreeTransactionID,IMT.HierarchyFourTransactionID,IMT.HierarchyFiveTransactionID,IMT.HierarchySixTransactionID
,ISNULL(ITP.IsEnabled,0) as IsEnabled,TD.TowerName,TD.InfraTowerTransactionID,IMT.CustomerID ,
IMT.InfraTransMappingID,IMT.InfraMasterMappingID
INTO #TmpHierarchyDet
 from   AVL.InfraHierarchyMappingTransaction IMT  
JOIN AVL.InfraTowerDetailsTransaction TD ON TD.InfraTransMappingID=IMT.InfraTransMappingID AND TD.CustomerID=IMT.CustomerID  AND IMT.CustomerID=@CustomerID
AND ISNULL(IMT.IsDeleted,0)=0 AND TD.IsDeleted=0

 LEFT JOIN AVL.InfraTowerProjectMapping ITP ON ITP.TowerID=TD.InfraTowerTransactionID AND ITP.ProjectID=@ProjectID
  AND ITP.ISDELETED=0 ORDER BY TD.TowerName ASC


  --DROP TABLE #TmpHierarchyDet

  SELECT

  DISTINCT
  ISNULL(IMT.IsEnabled,0) AS Checked,0 as 'HasTickets',IMT.InfraTowerTransactionID,IMT.TowerName,Null as 'MainspringSupportID',Null as 'MainspringSupportName',
   HTO.HierarchyName AS HierarchyOneTransaction,HTO.HierarchyOneTransactionID 
  ,HTT.HierarchyName AS HierarchyTwoTransaction,HTT.HierarchyTwoTransactionID ,
  HTTH.HierarchyName AS HierarchyThreeTransaction,HTTH.HierarchyThreeTransactionID,
 CASE WHEN @CountForColumn>=4 THEN HTTF.HierarchyName ELSE '' END AS  HierarchyFourTransaction ,
  CASE WHEN @CountForColumn>=4 THEN HTTF.HierarchyFourTransactionID ELSE '' END AS  HierarchyFourTransactionID ,
 CASE WHEN @CountForColumn>=5 THEN  HTTV.HierarchyName ELSE '' END  AS HierarchyFiveTransaction,
  CASE WHEN @CountForColumn>=5 THEN  HTTV.HierarchyFiveTransactionID ELSE '' END  AS HierarchyFiveTransactionID,
 CASE WHEN @CountForColumn>=6 THEN HST.HierarchyName ELSE '' END AS HierarchySixTransaction,
  CASE WHEN @CountForColumn>=6 THEN HST.HierarchySixTransactionID ELSE '' END AS HierarchySixTransactionID,
  CASE WHEN IMT.IsEnabled=1 THEN 'Yes' else 'No' End AS IsEnabled
    ,@accessToPM AS  'AccessToPM'
 

 from #TmpHierarchyDet IMT 
  JOIN AVL.InfraHierarchyOneTransaction HTO 
ON IMT.HierarchyOneTransactionID=HTO.HierarchyOneTransactionID AND IMT.CustomerID=HTO.CustomerID
  AND HTO.CustomerID=@CustomerID AND ISNULL(HTO.IsDeleted,0)=0 
  JOIN AVL.InfraHierarchyTwoTransaction HTT
ON IMT.HierarchyTwoTransactionID=HTT.HierarchyTwoTransactionID AND IMT.CustomerID=HTT.CustomerID
  AND HTT.CustomerID=@CustomerID AND ISNULL(HTT.IsDeleted,0)=0
  JOIN AVL.InfraHierarchyThreeTransaction HTTH
  ON HTTH.HierarchyThreeTransactionID=IMT.HierarchyThreeTransactionID AND HTTH.CustomerID=IMT.CustomerID
  AND IMT.CustomerID=@CustomerID AND ISNULL(HTTH.IsDeleted,0)=0
 
 LEFT JOIN AVL.InfraHierarchyFourTransaction HTTF ON IMT.HierarchyFourTransactionID=HTTF.HierarchyFourTransactionID
  AND IMT.CustomerID=HTTF.CustomerID
  AND HTTF.CustomerID=@CustomerID AND ISNULL(HTTF.IsDeleted,0)=0 

  left JOIN avl.InfraHierarchyFiveTransaction HTTV ON HTTV.HierarchyFiveTransactionID=IMT.HierarchyFiveTransactionID
  AND IMT.CustomerID=HTTV.CustomerID AND ISNULL(HTTV.IsDeleted,0)=0 

  LEFT JOIN AVL.InfraHierarchySixTransaction HST ON HST.HierarchySixTransactionID=IMT.HierarchySixTransactionID
  AND HST.CustomerID=IMT.CustomerID
  AND ISNULL(HST.IsDeleted,0)=0
 ORDER BY IMT.TowerName ASC, IsEnabled DESC
  END TRY

  BEGIN CATCH
    DECLARE @ErrorMessage VARCHAR(MAX);

                SELECT @ErrorMessage = ERROR_MESSAGE()

               	EXEC AVL_InsertError ' [AVL].[Infra_GetTowerProjectMappingDetails]', @ErrorMessage, 0,0
  END CATCH
END
