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
-- Author    :    Dhivya Bharathi M    
--  Create date:    April 17 2019     
--DROP PROCEDURE [AVL].[Infra_SaveHierarchyLevelValues]  
-- ============================================================================  
CREATE PROCEDURE [AVL].[Infra_SaveHierarchyLevelValues]  
@InfraHierarchyNames AVL.TVP_InfraHierarchyNames READONLY  
  
  
AS  
BEGIN  
 BEGIN TRY  
  DECLARE @CustomerID BIGINT;  
  
  CREATE TABLE #Infra_HierarchyNames  
  (  
   CustomerID BIGINT NOT NULL,  
   Mode INT NULL,  
   HierarchyName NVARCHAR(MAX) NULL,  
   CreatedBy NVARCHAR(50) NULL  
  )  
  INSERT INTO #Infra_HierarchyNames  
  SELECT CustomerID,Mode,HierarchyName,CreatedBy FROM @InfraHierarchyNames  
  WHERE HierarchyName IS NOT NULL AND HierarchyName != ''  
  SET @CustomerID=(SELECT TOP 1 CustomerID FROM #Infra_HierarchyNames)  
  --One Level  
  MERGE AVL.InfraHierarchyOneTransaction IHOT  
  USING #Infra_HierarchyNames IHN  
  ON IHOT.CustomerID=IHN.CustomerID  
  AND IHOT.HierarchyName = IHN.HierarchyName   
  WHEN MATCHED AND IHN.Mode=1 THEN  
  UPDATE  
  SET   
  IHOT.ModifiedBy=IHN.CreatedBy,  
  IHOT.ModifiedDate=GETDATE()  
  WHEN NOT MATCHED  BY TARGET AND IHN.Mode=1 THEN  
  INSERT (CustomerID,HierarchyName,IsDeleted,CreatedBy,CreatedDate)  
  VALUES (IHN.CustomerID,IHN.HierarchyName,0,IHN.CreatedBy,GETDATE());  
  
  --Two Level  
  MERGE AVL.InfraHierarchyTwoTransaction IHOT  
  USING #Infra_HierarchyNames IHN  
  ON IHOT.CustomerID=IHN.CustomerID  
  AND IHOT.HierarchyName = IHN.HierarchyName   
  WHEN MATCHED AND IHN.Mode=2 THEN  
  UPDATE  
  SET   
  IHOT.ModifiedBy=IHN.CreatedBy,  
  IHOT.ModifiedDate=GETDATE()  
  WHEN NOT MATCHED  BY TARGET AND IHN.Mode=2 THEN  
  INSERT (CustomerID,HierarchyName,IsDeleted,CreatedBy,CreatedDate)  
  VALUES (IHN.CustomerID,IHN.HierarchyName,0,IHN.CreatedBy,GETDATE());  
  
  --Three Level  
  MERGE AVL.InfraHierarchyThreeTransaction IHOT  
  USING #Infra_HierarchyNames IHN  
  ON IHOT.CustomerID=IHN.CustomerID  
  AND IHOT.HierarchyName = IHN.HierarchyName   
  WHEN MATCHED AND IHN.Mode=3 THEN  
  UPDATE  
  SET   
  IHOT.ModifiedBy=IHN.CreatedBy,  
  IHOT.ModifiedDate=GETDATE()  
  WHEN NOT MATCHED  BY TARGET AND IHN.Mode=3 THEN  
  INSERT (CustomerID,HierarchyName,IsDeleted,CreatedBy,CreatedDate)  
  VALUES (IHN.CustomerID,IHN.HierarchyName,0,IHN.CreatedBy,GETDATE());  
  
  --Four Level  
  MERGE AVL.InfraHierarchyFourTransaction IHOT  
  USING #Infra_HierarchyNames IHN  
  ON IHOT.CustomerID=IHN.CustomerID  
  AND IHOT.HierarchyName = IHN.HierarchyName   
  WHEN MATCHED AND IHN.Mode=4 THEN  
  UPDATE  
  SET   
  IHOT.ModifiedBy=IHN.CreatedBy,  
  IHOT.ModifiedDate=GETDATE()  
  WHEN NOT MATCHED  BY TARGET AND IHN.Mode=4 THEN  
  INSERT (CustomerID,HierarchyName,IsDeleted,CreatedBy,CreatedDate)  
  VALUES (IHN.CustomerID,IHN.HierarchyName,0,IHN.CreatedBy,GETDATE());  
  
  --Five Level  
  MERGE AVL.InfraHierarchyFiveTransaction IHOT  
  USING #Infra_HierarchyNames IHN  
  ON IHOT.CustomerID=IHN.CustomerID  
  AND IHOT.HierarchyName = IHN.HierarchyName   
  WHEN MATCHED AND IHN.Mode=5 THEN  
  UPDATE  
  SET   
  IHOT.ModifiedBy=IHN.CreatedBy,  
  IHOT.ModifiedDate=GETDATE()  
  WHEN NOT MATCHED  BY TARGET AND IHN.Mode=5 THEN  
  INSERT (CustomerID,HierarchyName,IsDeleted,CreatedBy,CreatedDate)  
  VALUES (IHN.CustomerID,IHN.HierarchyName,0,IHN.CreatedBy,GETDATE());  
  
  --Six Level  
  MERGE AVL.InfraHierarchySixTransaction IHOT  
  USING #Infra_HierarchyNames IHN  
  ON IHOT.CustomerID=IHN.CustomerID  
  AND IHOT.HierarchyName = IHN.HierarchyName   
  WHEN MATCHED AND IHN.Mode=6 THEN  
  UPDATE  
  SET   
  IHOT.ModifiedBy=IHN.CreatedBy,  
  IHOT.ModifiedDate=GETDATE()  
  WHEN NOT MATCHED  BY TARGET AND IHN.Mode=6 THEN  
  INSERT (CustomerID,HierarchyName,IsDeleted,CreatedBy,CreatedDate)  
  VALUES (IHN.CustomerID,IHN.HierarchyName,0,IHN.CreatedBy,GETDATE());  
  
    
  SELECT CustomerID,1 AS Mode,HierarchyName,HierarchyOneTransactionID AS HierarchyTransactionID  
  FROM AVL.InfraHierarchyOneTransaction(NOLOCK)   
  WHERE CustomerID=@CustomerID AND IsDeleted=0  
  UNION  
  SELECT CustomerID,2 AS Mode,HierarchyName,HierarchyTwoTransactionID AS HierarchyTransactionID  
  FROM AVL.InfraHierarchyTwoTransaction(NOLOCK)   
  WHERE CustomerID=@CustomerID AND IsDeleted=0  
  UNION  
  SELECT CustomerID,3 AS Mode ,HierarchyName,HierarchyThreeTransactionID AS HierarchyTransactionID  
  FROM AVL.InfraHierarchyThreeTransaction(NOLOCK)  
  WHERE CustomerID=@CustomerID AND IsDeleted=0  
  UNION  
  SELECT CustomerID,4 AS Mode ,HierarchyName,HierarchyFourTransactionID AS HierarchyTransactionID  
  FROM AVL.InfraHierarchyFourTransaction(NOLOCK)   
  WHERE CustomerID=@CustomerID AND IsDeleted=0  
  UNION  
  SELECT CustomerID,5 AS Mode,HierarchyName ,HierarchyFiveTransactionID AS HierarchyTransactionID  
  FROM AVL.InfraHierarchyFiveTransaction(NOLOCK)   
  WHERE CustomerID=@CustomerID AND IsDeleted=0  
  UNION  
  SELECT CustomerID,6 AS Mode,HierarchyName , HierarchySixTransactionID AS HierarchyTransactionID  
  FROM AVL.InfraHierarchySixTransaction(NOLOCK)   
  WHERE CustomerID=@CustomerID AND IsDeleted=0  
  
  
 END TRY    
 BEGIN CATCH    
  SELECT CustomerID,1 AS Mode,HierarchyName,HierarchyOneTransactionID AS HierarchyTransactionID  
  FROM AVL.InfraHierarchyOneTransaction(NOLOCK)   
  WHERE CustomerID=@CustomerID AND IsDeleted=0  
  UNION  
  SELECT CustomerID,2 AS Mode,HierarchyName,HierarchyTwoTransactionID AS HierarchyTransactionID  
  FROM AVL.InfraHierarchyTwoTransaction(NOLOCK)   
  WHERE CustomerID=@CustomerID AND IsDeleted=0  
  UNION  
  SELECT CustomerID,3 AS Mode ,HierarchyName,HierarchyThreeTransactionID AS HierarchyTransactionID  
  FROM AVL.InfraHierarchyThreeTransaction(NOLOCK)  
  WHERE CustomerID=@CustomerID AND IsDeleted=0  
  UNION  
  SELECT CustomerID,4 AS Mode ,HierarchyName,HierarchyFourTransactionID AS HierarchyTransactionID  
  FROM AVL.InfraHierarchyFourTransaction(NOLOCK)   
  WHERE CustomerID=@CustomerID AND IsDeleted=0  
  UNION  
  SELECT CustomerID,5 AS Mode,HierarchyName ,HierarchyFiveTransactionID AS HierarchyTransactionID  
  FROM AVL.InfraHierarchyFiveTransaction(NOLOCK)   
  WHERE CustomerID=@CustomerID AND IsDeleted=0  
  UNION  
  SELECT CustomerID,6 AS Mode,HierarchyName , HierarchySixTransactionID AS HierarchyTransactionID  
  FROM AVL.InfraHierarchySixTransaction(NOLOCK)   
  WHERE CustomerID=@CustomerID AND IsDeleted=0  
   DECLARE @ErrorMessage VARCHAR(MAX);  
   SELECT @ErrorMessage = ERROR_MESSAGE()  
   EXEC AVL_InsertError '[AVL].[Infra_SaveHierarchyLevelValues]', @ErrorMessage, 0,0  
  END CATCH    
END
