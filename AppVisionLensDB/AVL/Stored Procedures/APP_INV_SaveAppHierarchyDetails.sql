/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
              
CREATE PROCEDURE [AVL].[APP_INV_SaveAppHierarchyDetails]               
  @CognizantId NVARCHAR(100) =NULL,            
 @CustomerID int=Null                
AS              
              
BEGIN              
              
BEGIN TRY              
            
SET NOCOUNT ON;              
DECLARE @Hierarchy1 AS TABLE(HierarchyValue VARCHAR(250),              
              
HierarchyName VARCHAR(100),              
              
ClusterID BIGINT)              
DECLARE @Hierarchy2 AS TABLE(HierarchyValue VARCHAR(250),              
HierarchyName VARCHAR(100),              
HierarchyParentName VARCHAR(100),              
ClusterID BIGINT,              
BusinessClusterMapID BIGINT)               
DECLARE @Hierarchy3 AS TABLE(HierarchyValue VARCHAR(250),              
              
HierarchyName VARCHAR(100),              
              
HierarchyParentName VARCHAR(100),              
              
Hierarchy1 VARCHAR(100) NULL,              
              
ClusterID BIGINT,              
              
BusinessClusterMapID BIGINT)              
DECLARE @Hierarchy4 AS TABLE(HierarchyValue VARCHAR(250),              
HierarchyName VARCHAR(100),              
              
HierarchyParentName VARCHAR(100),              
              
Hierarchy1 VARCHAR(100) NULL,              
              
Hierarchy2 VARCHAR(100) NULL,              
              
ClusterID BIGINT,              
              
BusinessClusterMapID BIGINT)              
              
              
              
DECLARE @Hierarchy5 AS TABLE(HierarchyValue VARCHAR(250),              
              
HierarchyName VARCHAR(100),              
              
HierarchyParentName VARCHAR(100),              
              
Hierarchy1 VARCHAR(100) NULL,              
              
Hierarchy2 VARCHAR(100) NULL,              
              
Hierarchy3 VARCHAR(100) NULL,              
              
ClusterID BIGINT,              
              
BusinessClusterMapID BIGINT)              
              
              
              
DECLARE @Hierarchy6 AS TABLE(HierarchyValue VARCHAR(250),              
              
HierarchyName VARCHAR(100),              
              
HierarchyParentName VARCHAR(100),              
              
Hierarchy1 VARCHAR(100) NULL,              
              
Hierarchy2 VARCHAR(100) NULL,              
              
Hierarchy3 VARCHAR(100) NULL,              
              
Hierarchy4 VARCHAR(100) NULL,              
              
ClusterID BIGINT,              
              
BusinessClusterMapID BIGINT)              
              
              
              
DECLARE @Hierarchy1Count BIGINT              
              
DECLARE @Hierarchy2Count BIGINT              
              
DECLARE @Hierarchy3Count BIGINT              
              
DECLARE @Hierarchy4Count BIGINT              
              
DECLARE @Hierarchy5Count BIGINT              
              
DECLARE @Hierarchy6Count BIGINT              
              
              
              
DECLARE @Hierarchy1ClusterID BIGINT              
              
DECLARE @Hierarchy2ClusterID BIGINT              
              
DECLARE @Hierarchy3ClusterID BIGINT              
              
DECLARE @Hierarchy4ClusterID BIGINT              
              
DECLARE @Hierarchy5ClusterID BIGINT              
              
DECLARE @Hierarchy6ClusterID BIGINT              
              
              
              
              
DECLARE @ClusterCount BIGINT              
              
              
              
DECLARE @DistinctHierarchyCount BIGINT              
              
              
              
DECLARE @HierarchyTempCount BIGINT              
              
              
              
SELECT              
 @ClusterCount = COUNT(*)              
FROM AVL.BusinessCluster              
WHERE CustomerID = @CustomerID              
        
IF OBJECT_ID('tempdb.dbo.#ApplicationHierarchyTemp  ', 'U') IS NOT NULL
  DROP TABLE  #ApplicationHierarchyTemp ;             
              
              
SELECT              
 * INTO #ApplicationHierarchyTemp              
FROM [dbo].[ApplicationHierarchyTemp]              
WHERE CustomerId = @CustomerID              
              
              
              
--SET @HierarchyTempCount = (SELECT              
--  COUNT(*)           
-- FROM #ApplicationHierarchyTemp)              
              
              
              
IF @ClusterCount = 3 BEGIN              
              
DELETE FROM #ApplicationHierarchyTemp              
              
WHERE Hierarchy3 IN (SELECT              
   BusinessClusterBaseName              
  FROM AVL.BusinessClusterMapping              
  WHERE CustomerID = @CustomerID              
  AND IsHavingSubBusinesss = 0              
  AND IsDeleted = 0)              
              
  SET @HierarchyTempCount = (SELECT              
  COUNT(*)           
 FROM #ApplicationHierarchyTemp)              
              
SET @DistinctHierarchyCount = (SELECT              
  COUNT(DISTINCT Hierarchy3)              
 FROM #ApplicationHierarchyTemp)              
              
END ELSE IF @ClusterCount = 4 BEGIN              
              
DELETE FROM #ApplicationHierarchyTemp              
              
WHERE Hierarchy4 IN (SELECT              
   BusinessClusterBaseName              
  FROM AVL.BusinessClusterMapping              
  WHERE CustomerID = @CustomerID              
  AND IsHavingSubBusinesss = 0              
  AND IsDeleted = 0)              
              
   SET @HierarchyTempCount = (SELECT              
  COUNT(*)           
 FROM #ApplicationHierarchyTemp)             
              
SET @DistinctHierarchyCount = (SELECT              
  COUNT(DISTINCT Hierarchy4)              
 FROM #ApplicationHierarchyTemp)              
              
END ELSE IF @ClusterCount = 5 BEGIN              
              
DELETE FROM #ApplicationHierarchyTemp              
              
WHERE Hierarchy5 IN (SELECT              
   BusinessClusterBaseName              
  FROM AVL.BusinessClusterMapping              
  WHERE CustomerID = @CustomerID              
  AND IsHavingSubBusinesss = 0              
  AND IsDeleted = 0)              
              
            SET @HierarchyTempCount = (SELECT              
  COUNT(*)           
 FROM #ApplicationHierarchyTemp)    
              
SET @DistinctHierarchyCount = (SELECT              
  COUNT(DISTINCT Hierarchy5)              
 FROM #ApplicationHierarchyTemp)              
              
END ELSE IF @ClusterCount = 6 BEGIN              
              
DELETE FROM #ApplicationHierarchyTemp              
              
WHERE Hierarchy6 IN (SELECT              
   BusinessClusterBaseName              
  FROM AVL.BusinessClusterMapping              
  WHERE CustomerID = @CustomerID              
  AND IsHavingSubBusinesss = 0              
  AND IsDeleted = 0)              
              
              
              SET @HierarchyTempCount = (SELECT              
  COUNT(*)           
 FROM #ApplicationHierarchyTemp)  
SET @DistinctHierarchyCount = (SELECT              
  COUNT(DISTINCT Hierarchy6)              
 FROM #ApplicationHierarchyTemp)              
              
END              
              
              
              
IF @ClusterCount = 3 AND EXISTS (SELECT              
  *              
 FROM #ApplicationHierarchyTemp              
 WHERE Hierarchy3 IS NULL              
 OR Hierarchy2 IS NULL              
 OR Hierarchy1 IS NULL              
 OR Hierarchy4 IS NOT NULL              
 OR Hierarchy5 IS NOT NULL              
 OR Hierarchy6 IS NOT NULL) BEGIN              
              
SELECT              
 2 AS Result              
              
END ELSE IF @ClusterCount = 4 AND EXISTS (SELECT              
  *              
 FROM #ApplicationHierarchyTemp              
 WHERE Hierarchy4 IS NULL              
 OR Hierarchy3 IS NULL              
 OR Hierarchy2 IS NULL              
 OR Hierarchy1 IS NULL              
 OR Hierarchy5 IS NOT NULL              
 OR Hierarchy6 IS NOT NULL) BEGIN              
              
SELECT              
 2 AS Result              
              
END ELSE IF @ClusterCount = 5 AND EXISTS (SELECT              
  *              
 FROM #ApplicationHierarchyTemp              
 WHERE Hierarchy5 IS NULL              
 OR Hierarchy4 IS NULL              
 OR Hierarchy3 IS NULL              
 OR Hierarchy2 IS NULL              
 OR Hierarchy1 IS NULL              
 OR Hierarchy6 IS NOT NULL) BEGIN              
              
SELECT           
 2 AS Result              
              
END ELSE IF @ClusterCount = 6 AND EXISTS (SELECT              
  *              
 FROM #ApplicationHierarchyTemp              
 WHERE Hierarchy6 IS NULL              
 OR Hierarchy5 IS NULL              
 OR Hierarchy4 IS NULL              
 OR Hierarchy3 IS NULL              
 OR Hierarchy2 IS NULL              
 OR Hierarchy1 IS NULL) BEGIN              
              
SELECT              
 2 AS Result              
              
END ELSE IF (@DistinctHierarchyCount != @HierarchyTempCount) or (@DistinctHierarchyCount = 0 and @HierarchyTempCount = 0) BEGIN            
              
SELECT              
 0 AS Result              
              
END ELSE BEGIN              
              
              
              
              
              
IF EXISTS (SELECT              
              
  1              
              
 FROM AVL.PRJ_ConfigurationProgress              
              
 WHERE ScreenID = 1              
 AND CustomerID = @CustomerID) BEGIN              
              
IF NOT EXISTS (SELECT              
  1              
 FROM AVL.BusinessClusterMapping              
 WHERE CustomerID = @CustomerID              
 AND IsDeleted = 0) BEGIN              
              
UPDATE AVL.PRJ_ConfigurationProgress              
SET CompletionPercentage = 50              
 ,ModifiedBy = @CognizantId              
 ,ModifiedDate = GETDATE()              
              
WHERE CustomerID = @CustomerID              
AND ScreenID = 1              
              
END              
              
END              
              
              
              
              
              
              
SELECT              
 @Hierarchy1Count = COUNT(DISTINCT Hierarchy1)              
FROM #ApplicationHierarchyTemp              
              
              
              
SELECT              
 @Hierarchy2Count = COUNT(DISTINCT Hierarchy2)              
FROM #ApplicationHierarchyTemp              
              
              
              
SELECT              
 @Hierarchy3Count = COUNT(DISTINCT Hierarchy3)              
FROM #ApplicationHierarchyTemp              
              
              
              
SELECT              
 @Hierarchy4Count = COUNT(DISTINCT Hierarchy4)              
FROM #ApplicationHierarchyTemp              
              
              
              
SELECT              
 @Hierarchy5Count = COUNT(DISTINCT Hierarchy5)              
FROM #ApplicationHierarchyTemp              
              
              
              
SELECT              
 @Hierarchy6Count = COUNT(DISTINCT Hierarchy6)              
FROM #ApplicationHierarchyTemp              
              
              
              
              
              
              
INSERT INTO @Hierarchy1              
              
 SELECT              
              
 DISTINCT              
  Hierarchy1              
  ,NULL              
  ,NULL              
              
 FROM #ApplicationHierarchyTemp              
              
              
              
              
SELECT              
 @Hierarchy2Count = COUNT(DISTINCT Hierarchy2)              
FROM #ApplicationHierarchyTemp              
              
              
              
INSERT INTO @Hierarchy2              
              
 SELECT              
              
 DISTINCT              
  Hierarchy2              
  ,NULL              
  ,H1.HierarchyValue              
  ,NULL              
  ,NULL              
              
 FROM #ApplicationHierarchyTemp AT              
              
 INNER JOIN @Hierarchy1 H1              
  ON H1.HierarchyValue = AT.Hierarchy1              
              
         
              
              
              
SELECT              
 @Hierarchy3Count = COUNT(DISTINCT Hierarchy3)              
FROM #ApplicationHierarchyTemp              
              
              
              
INSERT INTO @Hierarchy3              
              
 SELECT              
              
 DISTINCT              
  Hierarchy3              
  ,NULL              
  ,H2.HierarchyValue              
  ,H1.HierarchyValue              
  ,NULL              
  ,NULL              
              
 FROM #ApplicationHierarchyTemp AT              
              
 INNER JOIN @Hierarchy1 H1              
  ON H1.HierarchyValue = AT.Hierarchy1              
              
 INNER JOIN @Hierarchy2 H2              
  ON H2.HierarchyValue = AT.Hierarchy2              
  AND H2.HierarchyParentName = H1.HierarchyValue              
              
              
      
              
              
SELECT              
 @Hierarchy4Count = COUNT(DISTINCT Hierarchy4)              
FROM #ApplicationHierarchyTemp              
              
              
              
INSERT INTO @Hierarchy4              
              
 SELECT              
              
 DISTINCT              
  Hierarchy4              
  ,NULL              
  ,H3.HierarchyValue              
  ,H1.HierarchyValue              
  ,H2.HierarchyValue              
  ,NULL              
  ,NULL              
              
 FROM #ApplicationHierarchyTemp AT              
              
 INNER JOIN @Hierarchy1 H1              
  ON H1.HierarchyValue = AT.Hierarchy1              
              
 INNER JOIN @Hierarchy2 H2              
  ON H2.HierarchyValue = AT.Hierarchy2              
  AND H2.HierarchyParentName = H1.HierarchyValue              
              
 INNER JOIN @Hierarchy3 H3              
  ON H3.HierarchyValue = AT.Hierarchy3        
  AND H3.HierarchyParentName = H2.HierarchyValue              
              
              
              
              
SELECT              
 @Hierarchy5Count = COUNT(DISTINCT Hierarchy5)              
FROM #ApplicationHierarchyTemp              
              
              
              
INSERT INTO @Hierarchy5              
              
 SELECT              
              
 DISTINCT              
  Hierarchy5              
  ,NULL              
  ,H4.HierarchyValue              
  ,H1.HierarchyValue              
  ,H2.HierarchyValue              
  ,H3.HierarchyValue              
  ,NULL              
  ,NULL              
              
 FROM #ApplicationHierarchyTemp AT              
              
 INNER JOIN @Hierarchy1 H1              
  ON H1.HierarchyValue = AT.Hierarchy1              
              
 INNER JOIN @Hierarchy2 H2              
  ON H2.HierarchyValue = AT.Hierarchy2              
  AND H2.HierarchyParentName = H1.HierarchyValue              
              
 INNER JOIN @Hierarchy3 H3              
  ON H3.HierarchyValue = AT.Hierarchy3              
  AND H3.HierarchyParentName = H2.HierarchyValue              
              
 INNER JOIN @Hierarchy4 H4              
  ON H4.HierarchyValue = AT.Hierarchy4              
  AND H4.HierarchyParentName = H3.HierarchyValue              
              
              
              
              
SELECT              
 @Hierarchy6Count = COUNT(DISTINCT Hierarchy6)              
FROM #ApplicationHierarchyTemp              
              
              
              
INSERT INTO @Hierarchy6              
              
 SELECT              
              
 DISTINCT              
  Hierarchy6              
  ,NULL              
  ,H5.HierarchyValue              
  ,H1.HierarchyValue              
  ,H2.HierarchyValue              
  ,H3.HierarchyValue              
  ,H4.HierarchyValue              
  ,NULL              
  ,NULL              
              
 FROM #ApplicationHierarchyTemp AT              
              
 INNER JOIN @Hierarchy1 H1              
  ON H1.HierarchyValue = AT.Hierarchy1              
              
 INNER JOIN @Hierarchy2 H2              
  ON H2.HierarchyValue = AT.Hierarchy2              
  AND H2.HierarchyParentName = H1.HierarchyValue              
             
 INNER JOIN @Hierarchy3 H3              
  ON H3.HierarchyValue = AT.Hierarchy3              
  AND H3.HierarchyParentName = H2.HierarchyValue              
              
 INNER JOIN @Hierarchy4 H4              
  ON H4.HierarchyValue = AT.Hierarchy4              
 AND H4.HierarchyParentName = H3.HierarchyValue              
              
 INNER JOIN @Hierarchy5 H5              
  ON H5.HierarchyValue = AT.Hierarchy5              
  AND H5.HierarchyParentName = H4.HierarchyValue              
              
              
              
              
              
SELECT              
              
 @Hierarchy1ClusterID = BusinessClusterID              
              
FROM AVL.BusinessCluster              
              
WHERE CustomerID = @CustomerID              
AND ParentBusinessClusterID IS NULL              
              
              
              
              
              
              
              
UPDATE @Hierarchy1              
              
SET ClusterID = @Hierarchy1ClusterID              
              
              
              
SELECT              
              
 @Hierarchy2ClusterID = BusinessClusterID     
              
FROM AVL.BusinessCluster              
              
WHERE ParentBusinessClusterID = @Hierarchy1ClusterID              
              
              
              
UPDATE @Hierarchy2              
              
SET ClusterID = @Hierarchy2ClusterID              
              
              
              
SELECT              
              
 @Hierarchy3ClusterID = BusinessClusterID              
              
FROM AVL.BusinessCluster              
              
WHERE ParentBusinessClusterID = @Hierarchy2ClusterID              
              
              
              
UPDATE @Hierarchy3              
              
SET ClusterID = @Hierarchy3ClusterID              
              
              
              
SELECT              
              
 @Hierarchy3ClusterID = BusinessClusterID              
              
FROM AVL.BusinessCluster              
              
WHERE ParentBusinessClusterID = @Hierarchy2ClusterID              
              
              
              
UPDATE @Hierarchy3              
SET ClusterID = @Hierarchy3ClusterID              
SELECT              
@Hierarchy4ClusterID = BusinessClusterID              
FROM AVL.BusinessCluster              
WHERE ParentBusinessClusterID = @Hierarchy3ClusterID              
UPDATE @Hierarchy4              
SET ClusterID = @Hierarchy4ClusterID                
SELECT              
@Hierarchy5ClusterID = BusinessClusterID              
FROM AVL.BusinessCluster              
WHERE ParentBusinessClusterID = @Hierarchy4ClusterID              
UPDATE @Hierarchy5              
SET ClusterID = @Hierarchy5ClusterID                
SELECT              
@Hierarchy6ClusterID = BusinessClusterID              
FROM AVL.BusinessCluster              
WHERE ParentBusinessClusterID = @Hierarchy5ClusterID              
UPDATE @Hierarchy6              
SET ClusterID = @Hierarchy6ClusterID              
MERGE AVL.BusinessClusterMapping BCM USING @Hierarchy1 H1 ON H1.HierarchyValue = BCM.BusinessClusterBaseName AND H1.ClusterID = BCM.BusinessClusterID AND BCM.CustomerID = @CustomerID             
WHEN MATCHED THEN UPDATE SET BCM.BusinessClusterBaseName = H1.HierarchyValue,              
BCM.BusinessClusterID = H1.ClusterID,              
BCM.ModifiedBy = @CognizantId,              
BCM.ModifiedDate = GETDATE(),              
BCM.IsDeleted = 0 WHEN NOT MATCHED THEN INSERT(BusinessClusterBaseName, BusinessClusterID, ParentBusinessClusterMapID, IsHavingSubBusinesss, IsDeleted, CustomerID, CreatedBy, CreatedDate)             
VALUES(H1.HierarchyValue, H1.ClusterID, NULL, 1, 0, @CustomerID, @CognizantId, GETDATE());              
UPDATE H2              
SET H2.BusinessClusterMapID = BCM.BusinessClusterMapID              
FROM @Hierarchy2 H2              
INNER JOIN @Hierarchy1 H1              
 ON H1.HierarchyValue = H2.HierarchyParentName              
INNER JOIN AVL.BusinessClusterMapping BCM              
 ON H1.ClusterID = BCM.BusinessClusterID              
 AND H1.HierarchyValue = BCM.BusinessClusterBaseName              
MERGE AVL.BusinessClusterMapping BCM USING @Hierarchy2 H2 ON H2.HierarchyValue = BCM.BusinessClusterBaseName AND H2.ClusterID = BCM.BusinessClusterID AND BCM.CustomerID = @CustomerID            
AND H2.BusinessClusterMapID = BCM.ParentBusinessClusterMapID             
WHEN MATCHED THEN UPDATE SET BCM.BusinessClusterBaseName = H2.HierarchyValue,              
BCM.BusinessClusterID = H2.ClusterID,              
BCM.ModifiedBy = @CognizantId,              
BCM.ModifiedDate = GETDATE(),              
BCM.IsDeleted = 0 WHEN NOT MATCHED THEN INSERT(BusinessClusterBaseName, BusinessClusterID, ParentBusinessClusterMapID, IsHavingSubBusinesss, IsDeleted, CustomerID, CreatedBy, CreatedDate)             
VALUES(H2.HierarchyValue, H2.ClusterID, BusinessClusterMapID, 1, 0,@CustomerID, @CognizantId, GETDATE());              
UPDATE H3              
SET H3.BusinessClusterMapID = BCM.BusinessClusterMapID              
FROM @Hierarchy3 H3              
INNER JOIN @Hierarchy2 H2              
 ON H2.HierarchyValue = H3.HierarchyParentName              
 AND H2.HierarchyParentName = H3.Hierarchy1              
INNER JOIN AVL.BusinessClusterMapping BCM              
 ON H2.ClusterID = BCM.BusinessClusterID              
 AND H2.HierarchyValue = BCM.BusinessClusterBaseName              
 AND H2.BusinessClusterMapID = BCM.ParentBusinessClusterMapID                
MERGE AVL.BusinessClusterMapping BCM USING @Hierarchy3 H3 ON H3.HierarchyValue = BCM.BusinessClusterBaseName AND H3.ClusterID = BCM.BusinessClusterID AND BCM.CustomerID = @CustomerID            
AND H3.BusinessClusterMapID = BCM.ParentBusinessClusterMapID WHEN             
MATCHED THEN UPDATE SET BCM.BusinessClusterBaseName = H3.HierarchyValue,              
BCM.BusinessClusterID = H3.ClusterID,              
BCM.ModifiedBy = @CognizantId,              
BCM.ModifiedDate = GETDATE(),              
BCM.IsDeleted = 0 WHEN NOT MATCHED THEN INSERT(BusinessClusterBaseName, BusinessClusterID, ParentBusinessClusterMapID, IsHavingSubBusinesss, IsDeleted, CustomerID, CreatedBy, CreatedDate)             
VALUES(H3.HierarchyValue, H3.ClusterID, H3.BusinessClusterMapID,              
CASE              
 WHEN (SELECT              
    COUNT(HierarchyValue)              
   FROM @Hierarchy4              
   WHERE HierarchyValue IS NOT NULL)              
  > 0 THEN 1              
 ELSE 0              
END,              
0, @CustomerID, @CognizantId, GETDATE());              
            
              
IF EXISTS (SELECT              
  HierarchyValue              
 FROM @Hierarchy4              
 WHERE HierarchyValue IS NOT NULL) BEGIN              
        UPDATE H4              
SET H4.BusinessClusterMapID = BCM.BusinessClusterMapID              
FROM @Hierarchy4 H4              
INNER JOIN @Hierarchy3 H3              
ON H3.HierarchyValue = H4.HierarchyParentName              
AND H3.HierarchyParentName = H4.Hierarchy2              
AND H3.Hierarchy1 = H4.Hierarchy1                
INNER JOIN AVL.BusinessClusterMapping BCM              
 ON H3.ClusterID = BCM.BusinessClusterID              
 AND H3.HierarchyValue = BCM.BusinessClusterBaseName              
 AND H3.BusinessClusterMapID = BCM.ParentBusinessClusterMapID               
            
MERGE AVL.BusinessClusterMapping BCM USING @Hierarchy4 H4 ON H4.HierarchyValue = BCM.BusinessClusterBaseName AND H4.ClusterID = BCM.BusinessClusterID AND BCM.CustomerID = @CustomerID AND             
H4.BusinessClusterMapID = BCM.ParentBusinessClusterMapID WHEN             
MATCHED THEN UPDATE SET BCM.BusinessClusterBaseName = H4.HierarchyValue,              
BCM.BusinessClusterID = H4.ClusterID,              
BCM.ModifiedBy = @CognizantId,              
BCM.ModifiedDate = GETDATE(),              
BCM.IsDeleted = 0 WHEN NOT MATCHED THEN INSERT(BusinessClusterBaseName, BusinessClusterID, ParentBusinessClusterMapID, IsHavingSubBusinesss, IsDeleted, CustomerID, CreatedBy, CreatedDate)             
VALUES(H4.HierarchyValue, H4.ClusterID, H4.BusinessClusterMapID,              
              
CASE              
 WHEN (SELECT              
    COUNT(HierarchyValue)              
   FROM @Hierarchy5              
   WHERE HierarchyValue IS NOT NULL)              
  > 0 THEN 1              
 ELSE 0              
END,              
              
0, @CustomerID, @CognizantId, GETDATE());              
                    
IF EXISTS (SELECT              
  HierarchyValue              
 FROM @Hierarchy5              
 WHERE HierarchyValue IS NOT NULL) BEGIN              
              
              
              
UPDATE H5              
              
SET H5.BusinessClusterMapID = BCM.BusinessClusterMapID              
              
FROM @Hierarchy5 H5              
              
INNER JOIN @Hierarchy4 H4              
 ON H4.HierarchyValue = H5.HierarchyParentName              
 AND H4.HierarchyParentName = H5.Hierarchy3              
 AND H4.Hierarchy2 = H5.Hierarchy2              
 AND H4.Hierarchy1 = H5.Hierarchy1              
              
INNER JOIN AVL.BusinessClusterMapping BCM              
 ON H4.ClusterID = BCM.BusinessClusterID              
 AND H4.HierarchyValue = BCM.BusinessClusterBaseName              
 AND H4.BusinessClusterMapID = BCM.ParentBusinessClusterMapID              
              
MERGE AVL.BusinessClusterMapping BCM USING @Hierarchy5 H5 ON H5.HierarchyValue = BCM.BusinessClusterBaseName AND H5.ClusterID = BCM.BusinessClusterID AND BCM.CustomerID = @CustomerID            
AND H5.BusinessClusterMapID = BCM.ParentBusinessClusterMapID WHEN            
MATCHED THEN UPDATE SET BCM.BusinessClusterBaseName = H5.HierarchyValue,              
              
BCM.BusinessClusterID = H5.ClusterID,              
              
BCM.ModifiedBy = @CognizantId,              
              
BCM.ModifiedDate = GETDATE(),              
              
BCM.IsDeleted = 0 WHEN NOT MATCHED THEN INSERT(BusinessClusterBaseName, BusinessClusterID, ParentBusinessClusterMapID, IsHavingSubBusinesss, IsDeleted, CustomerID, CreatedBy, CreatedDate)             
VALUES(H5.HierarchyValue, H5.ClusterID, H5.BusinessClusterMapID,              
              
CASE              
 WHEN (SELECT              
    COUNT(HierarchyValue)              
   FROM @Hierarchy6              
   WHERE HierarchyValue IS NOT NULL)              
  > 0 THEN 1              
 ELSE 0              
END,              
0, @CustomerID, @CognizantId, GETDATE());              
IF EXISTS (SELECT              
  HierarchyValue              
 FROM @Hierarchy6              
 WHERE HierarchyValue IS NOT NULL) BEGIN              
UPDATE H6               
SET H6.BusinessClusterMapID = BCM.BusinessClusterMapID               
FROM @Hierarchy6 H6               
INNER JOIN @Hierarchy5 H5              
 ON H5.HierarchyValue = H6.HierarchyParentName              
 AND H5.HierarchyParentName = H6.Hierarchy4              
 AND H5.Hierarchy3 = H6.Hierarchy3              
 AND H5.Hierarchy2 = H6.Hierarchy2              
 AND H5.Hierarchy1 = H6.Hierarchy1              
INNER JOIN AVL.BusinessClusterMapping BCM              
 ON H5.ClusterID = BCM.BusinessClusterID              
 AND H5.HierarchyValue = BCM.BusinessClusterBaseName              
 AND H5.BusinessClusterMapID = BCM.ParentBusinessClusterMapID              
              
MERGE AVL.BusinessClusterMapping BCM USING @Hierarchy6 H6 ON H6.HierarchyValue = BCM.BusinessClusterBaseName AND H6.ClusterID = BCM.BusinessClusterID AND BCM.CustomerID = @CustomerID        
AND H6.BusinessClusterMapID = BCM.ParentBusinessClusterMapID WHEN             
MATCHED THEN UPDATE SET BCM.BusinessClusterBaseName = H6.HierarchyValue,              
              
BCM.BusinessClusterID = H6.ClusterID,              
              
BCM.ModifiedBy = @CognizantId,              
              
BCM.ModifiedDate = GETDATE(),              
              
BCM.IsDeleted = 0 WHEN NOT MATCHED THEN INSERT(BusinessClusterBaseName, BusinessClusterID, ParentBusinessClusterMapID, IsHavingSubBusinesss, IsDeleted, CustomerID, CreatedBy, CreatedDate)        
VALUES(H6.HierarchyValue, H6.ClusterID, H6.BusinessClusterMapID, 0,        
          
            
 0, @CustomerID, @CognizantId, GETDATE());              
END              
END              
END              
DROP TABLE #ApplicationHierarchyTemp              
SELECT              
 1 AS Result               
END                
END TRY BEGIN CATCH              
DECLARE @ErrorMessage VARCHAR(MAX);              
SELECT              
 @ErrorMessage = ERROR_MESSAGE()              
EXEC AVL_InsertError '[AVL].[APP_INV_SaveAppHierarchyDetails]'              
      ,@ErrorMessage           
    ,@CognizantId              
      ,@CustomerID            
            
END CATCH              
              
END