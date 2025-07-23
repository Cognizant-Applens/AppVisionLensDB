/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ====================================================================
-- author:		
-- create date: 
-- Modified by : 686186
-- Modified For: RHMS CR
-- description: getting businesscluster data details using customerID and employeeid
-- ====================================================================

-- EXEC [dbo].[GetBusinessClusterData] 7097,'111094'
CREATE proc [dbo].[GetBusinessClusterData]         
@CustomerID int,        
@AssociateID varchar(50)        
as        
BEGIN         
BEGIN TRY        
      select Associateid, ESACustomerID into #tempAssociateRoleData        
  FROM RLE.VW_ProjectLevelRoleAccessDetails(nolock) ecpm         
  Where ecpm.Associateid = @AssociateID   
  
select DISTINCT BM.ParentBusinessClusterMapID        
INTO #ParentClusterID        
from AVL.BusinessClusterMapping BM        
INNER JOIN AVL.EmployeeSubClusterMapping ESM ON ESM.SubClusterId = BM.BusinessClusterMapID and ESM.CustomerID=BM.CustomerID        
INNER JOIN AVL.Customer C ON ESM.CustomerID=C.CustomerID        
INNER JOIN #tempAssociateRoleData ECPM on ECPM.Associateid=ESM.EmployeeID and ECPM.ESACustomerID=C.ESA_AccountId        
WHERE        
C.CustomerID = @CustomerID AND ECPM.Associateid=@AssociateID        
        
        
DECLARE @TempBC TABLE (        
 BusinessClusterMapID BIGINT        
 ,BusinessClusterBaseName VARCHAR(MAX)        
 ,BusinessClusterID BIGINT        
 ,ParentBusinessClusterMapID BIGINT        
)        
        
INSERT INTO @TempBC        
SELECT         
BM.BusinessClusterMapID,        
BM.BusinessClusterBaseName,        
BM.BusinessClusterID,        
BM.ParentBusinessClusterMapID        
FROM         
 AVL.BusinessClusterMapping BM        
 INNER JOIN AVL.EmployeeSubClusterMapping ESM ON ESM.SubClusterId = BM.BusinessClusterMapID and ESM.CustomerID=BM.CustomerID        
 INNER JOIN AVL.Customer C ON ESM.CustomerID=C.CustomerID        
 INNER JOIN #tempAssociateRoleData ECPM on ECPM.Associateid=ESM.EmployeeID and ECPM.ESACustomerID=C.ESA_AccountId        
WHERE         
 C.CustomerID = @CustomerID AND ECPM.Associateid=@AssociateID AND BM.IsDeleted =0        
UNION        
 SELECT         
   BusinessClusterMapID,        
   BusinessClusterBaseName,        
   BusinessClusterID,        
   ParentBusinessClusterMapID         
   FROM         
   AVL.BusinessClusterMapping         
   WHERE BusinessClusterMapID IN (SELECT * FROM #ParentClusterID) AND IsDeleted =0        
          
DECLARE @Count INT = 0        
DECLARE @Increment INT = 0        
WHILE @Count <> 1        
BEGIN        
   PRINT 'Inside WHILE LOOP';        
   --DECLARE @ID BIGINT        
   SET @Increment = @Increment+1        
   IF (SELECT COUNT(*) FROM @TempBC  WHERE ParentBusinessClusterMapID IS NULL) = 0        
   BEGIN        
   PRINT 'Inside IF LOOP';        
    INSERT INTO @TempBC        
    SELECT BusinessClusterMapID,BusinessClusterBaseName,BusinessClusterID,ParentBusinessClusterMapID FROM AVL.BusinessClusterMapping         
    WHERE BusinessClusterMapID IN (SELECT ParentBusinessClusterMapID FROM @TempBC WHERE ParentBusinessClusterMapID NOT IN (SELECT BusinessClusterMapID FROM @TempBC)) AND IsDeleted =0        
 END        
 ELSE        
 BEGIN        
  PRINT 'Inside ELSE LOOP';        
  SET @Count = 2        
  INSERT INTO @TempBC        
  SELECT BusinessClusterMapID,BusinessClusterBaseName,BusinessClusterID,ParentBusinessClusterMapID FROM AVL.BusinessClusterMapping          
  WHERE BusinessClusterMapID IN (SELECT ParentBusinessClusterMapID FROM @TempBC WHERE ParentBusinessClusterMapID NOT IN (SELECT BusinessClusterMapID FROM @TempBC)) AND ParentBusinessClusterMapID IS NULL AND IsDeleted =0        
 END        
 IF @Increment = 2000        
 BEGIN        
  PRINT 'INCREMENT'        
  SET @Count = 1        
 END         
END;        
        
SELECT BusinessClusterMapID AS SubClusterID,BusinessClusterBaseName,BusinessClusterID,ISNULL(ParentBusinessClusterMapID,0) AS ParentBusinessClusterMapID        
,DENSE_RANK() OVER  (ORDER BY BusinessClusterID ASC) AS RANK1        
  ,ROW_NUMBER() OVER(ORDER BY BusinessClusterID ASC) AS Row#         
   INTO #SubCluster FROM @TempBC ORDER BY BusinessClusterMapID ASC        
        
        
Select ROW_NUMBER() OVER(ORDER BY BusinessClusterID ASC) AS RowNumber, BusinessClusterID,BusinessClusterName         
from AVL.BusinessCluster where CustomerID =@CustomerID AND BusinessClusterID IN (SELECT DISTINCT BusinessClusterID FROM #SubCluster)        
        
SELECT * FROM #SubCluster ORDER BY Row# ASC         
  END TRY          
BEGIN CATCH          
        
  DECLARE @ErrorMessage VARCHAR(MAX);        
        
  SELECT @ErrorMessage = ERROR_MESSAGE()        
        
  --INSERT Error            
  EXEC AVL_InsertError '[dbo].[GetBusinessClusterData]', @ErrorMessage, 0,@CustomerID        
          
 END CATCH          
        
        
END
