/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[GetAppInventoryDetails_Transition]
@CustomerId varchar(50)=null,
@isCognizant varchar(10)=null
AS

BEGIN TRY
--if exists (select 1 from pp.Transition_AppInventroyAttributes where customerId = @CustomerId and isdeleted = 0)
IF OBJECT_ID('tempdb..#DropdownTemp') IS NOT NULL DROP TABLE #DropdownTemp 
CREATE TABLE #DropdownTemp
( ID int,
  AttributeValueName nvarchar(200),
   AttributeName varchar(50)
)
insert into #DropdownTemp
SELECT PPA.AttributeValueID AS ID, PPA.AttributeValueName AS AttributeValueName,pa.AttributeName as AttributeName 
			from Mas.PPAttributeValues (NOLOCK) PPA
			INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID 
			AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0
			WHERE pa.AttributeName = 'KTNeeded'

insert into #DropdownTemp
SELECT PPA.AttributeValueID AS ID, PPA.AttributeValueName AS AttributeValueName,pa.AttributeName as AttributeName
			from Mas.PPAttributeValues (NOLOCK) PPA
			INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID 
			AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0
			WHERE pa.AttributeName = 'CRType'

insert into #DropdownTemp
SELECT PPA.AttributeValueID AS ID, PPA.AttributeValueName AS AttributeValueName,pa.AttributeName as AttributeName
			from Mas.PPAttributeValues (NOLOCK) PPA
			INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID 
			AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0
			WHERE pa.AttributeName = 'Business Function'

insert into #DropdownTemp
SELECT PPA.AttributeValueID AS ID, PPA.AttributeValueName AS AttributeValueName,pa.AttributeName as AttributeName 
			from Mas.PPAttributeValues (NOLOCK) PPA
			INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID 
			AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0
			WHERE pa.AttributeName = 'Operationally Critical'

insert into #DropdownTemp
SELECT PPA.AttributeValueID AS ID, PPA.AttributeValueName AS AttributeValueName,pa.AttributeName as AttributeName 
			from Mas.PPAttributeValues (NOLOCK) PPA
			INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID 
			AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0
			WHERE pa.AttributeName = 'Security Critical'

insert into #DropdownTemp
SELECT PPA.AttributeValueID AS ID, PPA.AttributeValueName AS AttributeValueName,pa.AttributeName as AttributeName
			from Mas.PPAttributeValues (NOLOCK) PPA
			INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID 
			AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0
			WHERE pa.AttributeName = 'HighTouch'

insert into #DropdownTemp
			SELECT PPA.AttributeValueID AS ID, PPA.AttributeValueName AS AttributeValueName,pa.AttributeName as AttributeName 
			from Mas.PPAttributeValues (NOLOCK) PPA
			INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID 
			AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0
			WHERE pa.AttributeName = 'SLA Level'

select 
a.ApplicationName as ApplicationName,KT.AttributeValueName as [KTNeeded] ,[LanguageRequirements],
[WaveorCluster],[ApplicationOwnerIT],
CR.AttributeValueName as [CRType],
	[HardwareSoftwareRequirement],
BF.AttributeValueName as [BusinessFunction],
 OC.AttributeValueName  as [OperationallyCritical],
	SC.AttributeValueName as [SecurityCritical],	
	HT.AttributeValueName as [HighTouch],
	[PriceperMonth],
	SL.AttributeValueName as [SLALevel],
	[VendorTypeName],[VendorName],[OtherVendorTypeName] 
	from pp.Transition_AppInventroyAttributes(nolock) tra
	join avl.APP_MAS_ApplicationDetails(nolock) a on a.ApplicationID = tra.ApplicationId
	LEFT join #DropdownTemp KT on KT.ID = tra.KTNeeded and KT.AttributeName = 'KTNeeded'
	LEFT join #DropdownTemp CR on CR.ID = tra.CRType and CR.AttributeName = 'CRType'
	LEFT join #DropdownTemp BF on BF.ID = tra.BusinessFunction  and BF.AttributeName = 'Business Function'
	LEFT join #DropdownTemp OC on OC.ID = tra.OperationallyCritical and OC.AttributeName = 'Operationally Critical'
	LEFT join #DropdownTemp SC on SC.ID = tra.SecurityCritical  and SC.AttributeName = 'Security Critical'
	LEFT join #DropdownTemp HT on HT.ID = tra.HighTouch and HT.AttributeName = 'HighTouch'
	LEFT join #DropdownTemp SL on SL.ID = tra.SLALevel  and SL.AttributeName = 'SLA Level'
	where customerId = @CustomerId and isdeleted = 0

	Drop table #DropdownTemp

END TRY
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		
		EXEC AVL_InsertError '[PP].[GetAppInventoryDetails_Transition]', @ErrorMessage, @CustomerId
		
	END CATCH
