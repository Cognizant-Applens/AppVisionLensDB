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
--  Create date:    April 23 2019     
-- ============================================================================  
CREATE PROCEDURE [AVL].[Infra_SaveTowerDetailsTransaction]  
@InfraTowerDetailsTransaction [AVL].[TVP_InfraTowerDetailsTransaction] READONLY  
  
  
AS  
BEGIN  
	BEGIN TRY  
		DECLARE @CustomerID BIGINT; 
		DECLARE @CreatedBy NVARCHAR(50);  
		DECLARE @IsCognizant BIT;
	  CREATE TABLE #InfraTowerDetailsTransaction
	  (  
		[CustomerID] [bigint] NOT NULL,
		[InfraTransMappingID] [bigint] NOT NULL,
		[TowerName] [nvarchar](200) NULL,
		[ModeID] [int] NOT NULL,
		[CreatedBy] [nvarchar](50) NULL
	  )  

		SET @CustomerID=(SELECT TOP 1 CustomerID FROM @InfraTowerDetailsTransaction)
		 SET @CreatedBy=(SELECT TOP 1 CreatedBy FROM @InfraTowerDetailsTransaction)
		 SET @IsCognizant=(SELECT ISNULL(IsCognizant,0) FROM AVL.Customer WHERE CustomerID=@CustomerID)
		INSERT INTO #InfraTowerDetailsTransaction
		SELECT [CustomerID],[InfraTransMappingID],
		 [TowerName],[ModeID],[CreatedBy] FROM @InfraTowerDetailsTransaction
		  
		  MERGE AVL.InfraTowerDetailsTransaction TD
		  USING #InfraTowerDetailsTransaction IT 
		  ON TD.CustomerID=IT.CustomerID  
			AND TD.TowerName = IT.TowerName
		  WHEN MATCHED  THEN  
		  UPDATE  
		  SET
		  TD.[InfraTransMappingID]=IT.[InfraTransMappingID],
		  TD.[ModeID]=IT.ModeID,   
		  TD.ModifiedBy=IT.CreatedBy,  
		  TD.ModifiedDate=GETDATE()  
		  WHEN NOT MATCHED  BY TARGET  THEN  
		  INSERT ([CustomerID],[InfraTransMappingID],
		 [TowerName],[ModeID],[CreatedBy],CreatedDate,IsDeleted)  
		  VALUES (@CustomerID,IT.[InfraTransMappingID],
		 IT.TowerName,IT.ModeID,IT.[CreatedBy],GETDATE(),0);  
  
		SELECT InfraTowerTransactionID,CustomerID,InfraTransMappingID,TowerName,ModeID 
		FROM AVL.InfraTowerDetailsTransaction(NOLOCK) WHERE CustomerID=@CustomerID

		SELECT DISTINCT ITT.HierarchyName,ITT.CustomerID,ITM.HierarchyTwoMasterID AS HierarchyTwoID,IHMT.HierarchyTwoTransactionID AS HierarchyTwoTransactionID
		INTO #MasterHierarchy
		FROM AVL.InfraHierarchyTwoTransaction(NOLOCK) ITT
		INNER JOIN  AVL.InfraHierarchyMappingTransaction(NOLOCK) IHMT 
		ON ITT.CustomerID=IHMT.CustomerID AND ITT.HierarchyTwoTransactionID=IHMT.HierarchyTwoTransactionID 
		AND ISNULL(IHMT.IsDeleted,0)=0
		INNER JOIN AVL.InfraTowerDetailsTransaction ITD ON IHMT.CustomerID=ITD.CustomerID
		AND IHMT.InfraTransMappingID=ITD.InfraTransMappingID AND ISNULL(ITD.IsDeleted,0)=0
		INNER JOIN AVL.InfraHierarchyTwoMaster(NOLOCK) ITM ON ITT.HierarchyName=ITM.HierarchyName AND ISNULL(ITM.IsDeleted,0)=0
		WHERE IHMT.CustomerID=@CustomerID

		--Addition of Master Tasks
		--Getting the Tasks for the Level
		SELECT 
		DISTINCT	ITT.CustomerID,TM.InfraTaskName
		INTO #Tasks
		FROM  #MasterHierarchy ITT
		INNER JOIN AVL.InfraTaskMappingMaster(NOLOCK) ITM ON ITT.HierarchyTwoID=ITM.TechnologyTowerID
		INNER JOIN AVL.InfraTaskMaster(NOLOCK) TM ON ITM.InfraTaskID=TM.InfraTaskID 
		INNER JOIN AVL.MAS_ServiceLevel(NOLOCK) SL ON ITM.SupportLevelID=SL.ServiceLevelID 
		WHERE ITT.CustomerID=@CustomerID

		MERGE AVL.InfraTaskTransaction IHOT  
		USING #Tasks IHN  
		ON IHOT.CustomerID=IHN.CustomerID  
		AND IHOT.InfraTaskName = IHN.InfraTaskName   
		WHEN MATCHED 
		THEN  
		UPDATE  SET   
		IHOT.ModifiedBy=@CreatedBy,  
		IHOT.ModifiedDate=GETDATE(),
		IHOT.IsDeleted=0  
		WHEN NOT MATCHED  BY TARGET 
		THEN  
		INSERT (CustomerID,InfraTaskName,IsDeleted,CreatedBy,CreatedDate)  
		VALUES (IHN.CustomerID,IHN.InfraTaskName,0,@CreatedBy,GETDATE());  

		SELECT 
		DISTINCT ITT.CustomerID,ITT.HierarchyTwoTransactionID AS TechnologyTowerID,
		SL.ServiceLevelID,ITM.InfraTaskID AS InfraMasterTaskID,ITTN.InfraTransactionTaskID
		INTO #TransactionMapping
		FROM  #MasterHierarchy ITT
		INNER JOIN AVL.InfraTaskMappingMaster(NOLOCK) ITM ON ITT.HierarchyTwoID=ITM.TechnologyTowerID
		INNER JOIN AVL.InfraTaskMaster(NOLOCK) TM ON ITM.InfraTaskID=TM.InfraTaskID
		INNER JOIN AVL.InfraTaskTransaction(NOLOCK) ITTN ON ITTN.InfraTaskName=TM.InfraTaskName AND ISNULL(ITTN.IsDeleted,0)=0
		INNER JOIN AVL.MAS_ServiceLevel(NOLOCK) SL ON ITM.SupportLevelID=SL.ServiceLevelID AND ISNULL(SL.IsDeleted,0)=0
		WHERE ITTN.CustomerID=@CustomerID AND ITTN.IsDeleted=0

		MERGE  AVL.InfraTaskMappingTransaction IHOT  
		USING #TransactionMapping IHN  
		ON IHOT.CustomerID=IHN.CustomerID  
		AND IHOT.TechnologyTowerID = IHN.TechnologyTowerID   
		AND IHOT.SupportLevelID = IHN.ServiceLevelID   
		AND IHOT.InfraTransactionTaskID=IHN.InfraTransactionTaskID
		WHEN MATCHED 
		THEN  
		UPDATE  
		SET   
		IHOT.ModifiedBy=@CreatedBy , 
		IHOT.ModifiedDate=GETDATE(),
		IHOT.IsDeleted=0 
		WHEN NOT MATCHED  BY TARGET 
		THEN  
		INSERT (CUSTOMERID,[InfraMasterTaskMappingID],[TechnologyTowerID],[SupportLevelID],
		[InfraTransactionTaskID],[IsMaster],[IsEnabled],[IsDeleted]
		,[CreatedBy],[CreatedDate])
		VALUES (IHN.CustomerID,IHN.InfraMasterTaskID,IHN.TechnologyTowerID,IHN.ServiceLevelID,
		IHN.InfraTransactionTaskID,1,1,0,@CreatedBy,GETDATE()); 

		 UPDATE IMT 
		SET IMT.IsDeleted=1,IMT.ModifiedBy=@CreatedBy,IMT.ModifiedDate=GETDATE()
		FROM AVL.InfraTaskMappingTransaction(NOLOCK) IMT
		LEFT JOIN #MasterHierarchy MH ON IMT.TechnologyTowerID=MH.HierarchyTwoTransactionID
		WHERE IMT.CustomerID=@CustomerID AND ISNULL(IMT.IsDeleted,0)=0 AND MH.HierarchyTwoID IS NULL
		AND ISNULL(IMT.IsMaster,0) = 1
	

	IF(@IsCognizant=1)
	BEGIN	
	    UPDATE AVL.PRJ_ConfigurationProgress SET CompletionPercentage=50
		WHERE CustomerID=@CustomerID
		AND ScreenID=17 AND ISNULL(IsDeleted,0)=0 AND CompletionPercentage<50
	END
	ELSE
	BEGIN
		UPDATE AVL.PRJ_ConfigurationProgress SET CompletionPercentage=75
		WHERE CustomerID=@CustomerID
		AND ScreenID=17 AND ISNULL(IsDeleted,0)=0 
	END


	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX);  
		SELECT @ErrorMessage = ERROR_MESSAGE()  
		EXEC AVL_InsertError '[AVL].[Infra_SaveTowerDetailsTransaction]', @ErrorMessage, 0,0  
	END CATCH    
END
