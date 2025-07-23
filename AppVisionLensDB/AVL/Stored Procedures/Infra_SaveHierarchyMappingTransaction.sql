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
--  Create date:    April 22 2019     
-- ============================================================================  
CREATE PROCEDURE [AVL].[Infra_SaveHierarchyMappingTransaction]  
@InfraHierarchyMappingTransaction AVL.TVP_InfraHierarchyMappingTransaction READONLY  
  
  
AS  
BEGIN  
	BEGIN TRY  
		DECLARE @CustomerID BIGINT; 
		  
	  CREATE TABLE #InfraHierarchyMappingTransaction 
	  (  
	   [InfraTransMappingID] BIGINT NULL,
		[CustomerID] BIGINT NOT NULL,
		[InfraMasterMappingID] BIGINT NULL,
		[HierarchyOneTransactionID] BIGINT NOT NULL,
		[HierarchyTwoTransactionID] BIGINT NOT NULL,
		[HierarchyThreeTransactionID] BIGINT NOT NULL,
		[HierarchyFourTransactionID] BIGINT  NULL,
		[HierarchyFiveTransactionID] BIGINT  NULL,
		[HierarchySixTransactionID] BIGINT  NULL,
		[IsMaster] BIT  NULL,
		[CreatedBy] NVARCHAR(50) NULL
	  )  

		SET @CustomerID=(SELECT TOP 1 CustomerID FROM @InfraHierarchyMappingTransaction)
		INSERT INTO #InfraHierarchyMappingTransaction
		SELECT [InfraTransMappingID],[CustomerID],[InfraMasterMappingID],
		 [HierarchyOneTransactionID],[HierarchyTwoTransactionID],[HierarchyThreeTransactionID],
		 [HierarchyFourTransactionID],[HierarchyFiveTransactionID],[HierarchySixTransactionID],
		 [IsMaster],[CreatedBy] FROM @InfraHierarchyMappingTransaction
		  
		  MERGE AVL.InfraHierarchyMappingTransaction IHMT  
		  USING #InfraHierarchyMappingTransaction IHM 
		  ON IHMT.CustomerID=IHM.CustomerID  
			AND IHMT.[HierarchyOneTransactionID] = IHM.[HierarchyOneTransactionID]
			AND IHMT.[HierarchyTwoTransactionID]=IHM.[HierarchyTwoTransactionID]
			AND IHMT.[HierarchyThreeTransactionID]=IHM.[HierarchyThreeTransactionID]
			AND ISNULL(IHMT.[HierarchyFourTransactionID],0)=ISNULL(IHM.[HierarchyFourTransactionID],0)
			AND ISNULL(IHMT.[HierarchyFiveTransactionID],0)=ISNULL(IHM.[HierarchyFiveTransactionID],0)
			AND ISNULL(IHMT.[HierarchySixTransactionID],0)=ISNULL(IHM.[HierarchySixTransactionID],0)
		  WHEN MATCHED  THEN  
		  UPDATE  
		  SET   
		  IHMT.ModifiedBy=IHM.CreatedBy,  
		  IHMT.ModifiedDate=GETDATE()  
		  WHEN NOT MATCHED  BY TARGET  THEN  
		  INSERT ([CustomerID],[InfraMasterMappingID],
		 [HierarchyOneTransactionID],[HierarchyTwoTransactionID],[HierarchyThreeTransactionID],
		 [HierarchyFourTransactionID],[HierarchyFiveTransactionID],[HierarchySixTransactionID],
		 [IsMaster],[CreatedBy],CreatedDate,IsDeleted)  
		  VALUES (@CustomerID,IHM.[InfraMasterMappingID],
		 IHM.[HierarchyOneTransactionID],IHM.[HierarchyTwoTransactionID],IHM.[HierarchyThreeTransactionID],
		 IHM.[HierarchyFourTransactionID],IHM.[HierarchyFiveTransactionID],IHM.[HierarchySixTransactionID],
		 IHM.[IsMaster],IHM.[CreatedBy],GETDATE(),0);  
  
  SELECT InfraTransMappingID,[CustomerID],[InfraMasterMappingID],
		 [HierarchyOneTransactionID],[HierarchyTwoTransactionID],[HierarchyThreeTransactionID],
		 [HierarchyFourTransactionID],[HierarchyFiveTransactionID],[HierarchySixTransactionID],
		 [IsMaster],[CreatedBy]
		 FROM AVL.InfraHierarchyMappingTransaction(NOLOCK) WHERE CustomerID=@CustomerID

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX);  
		SELECT @ErrorMessage = ERROR_MESSAGE()  
		EXEC AVL_InsertError '[AVL].[Infra_SaveHierarchyMappingTransaction]', @ErrorMessage, 0,0  
	END CATCH    
END
