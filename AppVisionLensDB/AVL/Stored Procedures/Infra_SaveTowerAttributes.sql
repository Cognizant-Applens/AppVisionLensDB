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
CREATE PROCEDURE [AVL].[Infra_SaveTowerAttributes]  
@InfraTowerAttributes [AVL].[TVP_InfraTowerAttributes] READONLY  
  
  
AS  
BEGIN  
	BEGIN TRY  
		DECLARE @CustomerID BIGINT; 
	  CREATE TABLE #InfraTowerAttributes
	  (  
		[CustomerID] BIGINT NULL,
		[InfraTowerTransactionID] [bigint] NOT NULL,
		[Type] [nvarchar](50) NULL,
		[Item] [nvarchar](50) NULL,
		[CopyOrSerialNumber] [nvarchar](50) NULL,
		[ModelNumberHardware] [nvarchar](50) NULL,
		[WarrantyExpiryDate] [datetime] NULL,
		[SourceSupplier] [nvarchar](50) NULL,
		[License] [nvarchar](50) NULL,
		[SupplyDate] [date] NULL,
		[AcceptedDate] [date] NULL,
		[StatusScheduled] [nvarchar](50) NULL,
		[SLA] [int] NULL,
		[ServicePackAndPatchDetails] [nvarchar](50) NULL,
		[AdminGroups] [nvarchar](50) NULL,
		[UserGroups] [nvarchar](50) NULL,
		[IPAddress] [nvarchar](50) NULL,
		[CreatedBy] [nvarchar](50) NULL,
		[Name] [nvarchar](50) NULL,
		[ProductName] [nvarchar](50) NULL,
		[Function] [nvarchar](50) NULL,
		[Owner] [nvarchar](50) NULL,
		[Version] [nvarchar](50) NULL,
		[Contact] [nvarchar](50) NULL,
		[Category] [nvarchar](50) NULL,
		[ProductionDate] [date] NULL,
		[Hotfix] [nvarchar](50) NULL,
		[ServicePack] [nvarchar](50) NULL,
		[Supplier] [nvarchar](50) NULL,
		[Status] [nvarchar](50) NULL,
		[Location] [nvarchar](50) NULL,
		[NatureOfEmployment] [nvarchar](50) NULL
	  )  

		SET @CustomerID=(SELECT TOP 1 CustomerID FROM @InfraTowerAttributes)
		INSERT INTO #InfraTowerAttributes
		SELECT [CustomerID] ,
		[InfraTowerTransactionID],[Type],
		[Item] ,[CopyOrSerialNumber],[ModelNumberHardware],
		[WarrantyExpiryDate] ,[SourceSupplier],
		[License],[SupplyDate],
		[AcceptedDate],[StatusScheduled],
		[SLA] ,[ServicePackAndPatchDetails],
		[AdminGroups],[UserGroups],
		[IPAddress],[CreatedBy],[Name],[ProductName] ,
		[Function],[Owner] ,[Version],
		[Contact] ,[Category],[ProductionDate],
		[Hotfix],[ServicePack],
		[Supplier] ,[Status],
		[Location] ,[NatureOfEmployment]  FROM @InfraTowerAttributes
		  
		MERGE [AVL].[InfraTowerHardwareAttributes] TD
		USING #InfraTowerAttributes IT 
		ON TD.InfraTowerTransactionID = IT.InfraTowerTransactionID
		
		WHEN MATCHED  THEN  
		UPDATE  
		SET  
		TD.Type =IT.Type,
		TD.Item=IT.Item,
		TD.CopyOrSerialNumber=IT.CopyOrSerialNumber,
		TD.ModelNumberHardware=IT.ModelNumberHardware,
		TD.WarrantyExpiryDate=IT.WarrantyExpiryDate,
		TD.SourceSupplier=IT.SourceSupplier,
		TD.License=IT.License,
		TD.SupplyDate=IT.SupplyDate,
		TD.AcceptedDate=IT.AcceptedDate,
		TD.StatusScheduled=IT.StatusScheduled,
		TD.SLA=IT.SLA,
		TD.ServicePackAndPatchDetails=IT.ServicePackAndPatchDetails,
		TD.AdminGroups=IT.AdminGroups,
		TD.UserGroups=IT.UserGroups,
		TD.IPAddress=IT.IPAddress, 
		TD.ModifiedBy=IT.CreatedBy, TD.ModifiedDate=GETDATE()  ,TD.IsDeleted=0
		WHEN NOT MATCHED  BY TARGET  THEN  
		INSERT (InfraTowerTransactionID,Type,Item,CopyOrSerialNumber,ModelNumberHardware,
				WarrantyExpiryDate,SourceSupplier,License,SupplyDate,AcceptedDate,
				StatusScheduled,SLA,ServicePackAndPatchDetails,AdminGroups,
				UserGroups,IPAddress,CreatedBy,CreatedDate,IsDeleted)  
				VALUES (IT.InfraTowerTransactionID,IT.Type,IT.Item,IT.CopyOrSerialNumber,IT.ModelNumberHardware,
				IT.WarrantyExpiryDate,IT.SourceSupplier,IT.License,IT.SupplyDate,IT.AcceptedDate,
				IT.StatusScheduled,IT.SLA,IT.ServicePackAndPatchDetails,IT.AdminGroups,
				IT.UserGroups,IT.IPAddress,IT.CreatedBy,GETDATE(),0);  

		MERGE AVL.InfraTowerSoftwareAttributes TD
		USING #InfraTowerAttributes IT 
		ON TD.InfraTowerTransactionID = IT.InfraTowerTransactionID
		WHEN MATCHED  THEN  
		UPDATE  
		SET  
			TD.Name=IT.Name,
			TD.ProductName=IT.ProductName,
			TD.[Function]=IT.[Function],
			TD.Owner=IT.Owner,
			TD.Version=IT.Version,
			TD.Contact=IT.Contact,
			TD.Category=IT.Category,
			TD.ProductionDate=IT.ProductionDate,
			TD.Hotfix=IT.Hotfix,
			TD.ServicePack=IT.ServicePack,
			TD.Supplier=IT.Supplier,
			TD.Status=IT.Status,
		TD.ModifiedBy=IT.CreatedBy, TD.ModifiedDate=GETDATE() ,TD.IsDeleted=0 
		WHEN NOT MATCHED  BY TARGET  THEN  
		INSERT (InfraTowerTransactionID,Name,ProductName,[Function],
				Owner,Version,Contact,Category,ProductionDate,Hotfix,ServicePack,Supplier,
				Status,CreatedBy,CreatedDate,IsDeleted)  
				VALUES (IT.InfraTowerTransactionID,IT.Name,IT.ProductName,IT.[Function],
				IT.Owner,IT.Version,IT.Contact,IT.Category,IT.ProductionDate,IT.Hotfix,IT.ServicePack,IT.Supplier,
				IT.Status,IT.CreatedBy,GETDATE(),0);  

		MERGE AVL.InfraTowerPhysicalResourceAttributes TD
		USING #InfraTowerAttributes IT 
		ON TD.InfraTowerTransactionID = IT.InfraTowerTransactionID
		WHEN MATCHED  THEN  
		UPDATE  
		SET   
		TD.Location=IT.Location,
		TD.NatureOfEmployment=IT.NatureOfEmployment,
		TD.ModifiedBy=IT.CreatedBy, TD.ModifiedDate=GETDATE()  ,TD.IsDeleted=0
		WHEN NOT MATCHED  BY TARGET  THEN  
		INSERT (InfraTowerTransactionID,Location,NatureOfEmployment,CreatedBy,CreatedDate,IsDeleted)  
				VALUES (IT.InfraTowerTransactionID,IT.Location,IT.NatureOfEmployment,IT.CreatedBy,GETDATE(),0);  

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(MAX);  
		SELECT @ErrorMessage = ERROR_MESSAGE()  
		EXEC AVL_InsertError '[AVL].[Infra_SaveTowerAttributes]', @ErrorMessage, 0,0  
	END CATCH    
END
