/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [PP].[SaveAppInvTransitionAttributesBasedonApplication]
	@appid bigint = null,
	@ProjectID bigint=null,
	@cognizantId NVARCHAR(50),
	@customerId bigint,
	@TVP_AppInventoryUploadTransition [PP].[TVP_TransitionAppInventoryTempUpload]  READONLY  
AS
BEGIN
BEGIN TRY 
SET NOCOUNT ON;
BEGIN TRAN

IF OBJECT_ID('tempdb..#DropdownTemp') IS NOT NULL DROP TABLE #DropdownTemp 
IF OBJECT_ID('tempdb..#Existingapp') IS NOT NULL DROP TABLE #Existingapp

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

	 SELECT tra.ApplicationId,a.ApplicationName into #Existingapp
 FROM 
   pp.Transition_AppInventroyAttributes tra 
  join avl.APP_MAS_ApplicationDetails(nolock) a on a.ApplicationID = tra.ApplicationId
 where tra.ApplicationId=@appid
 and tra.IsDeleted='0' 

  IF exists(select top 1 * from #Existingapp)
 Begin
 ----existing app--------------
	update tra set tra.[KTNeeded] =KT.ID ,
 tra.[LanguageRequirements]=temp.[LanguageRequirements],
 tra.[WaveorCluster]=temp.[WaveOrCluster],
 tra.[ApplicationOwnerIT]= temp.[ApplicationOwnerIT],
 tra.[CRType]= CR.ID,
	tra.[HardwareSoftwareRequirement] =temp.[HardwareSoftwareRequirements],
	tra.[BusinessFunction] =BF.ID,
	tra.[OperationallyCritical] =OC.ID,
	tra.[SecurityCritical]=SC.ID,	
	tra.[HighTouch]=HT.ID,
	tra.[PriceperMonth] = temp.[PricePerMonth],
	tra.[SLALevel] =SL.ID,
	tra.[VendorTypeName] =temp.[VendorTypeName],
	tra.[VendorName]=temp.[VendorName],
	tra.[OtherVendorTypeName] = temp.[OtherVendorTypeName],
	tra.isdeleted = 0,
	tra.ModifiedDate = getdate() 
	from [PP].Transition_AppInventroyAttributes tra
	inner join #Existingapp a on tra.ApplicationId = a.ApplicationID
	inner join @TVP_AppInventoryUploadTransition temp on temp.ApplicationName = a.ApplicationName
	Left join #DropdownTemp KT on  LTRIM(RTRIM(KT.AttributeValueName)) = LTRIM(RTRIM(temp.KTNeeded)) and KT.AttributeName = 'KTNeeded'
	Left join #DropdownTemp CR on  LTRIM(RTRIM(CR.AttributeValueName)) = LTRIM(RTRIM(temp.CRType)) and CR.AttributeName = 'CRType'
	Left join #DropdownTemp BF on  LTRIM(RTRIM(BF.AttributeValueName)) = LTRIM(RTRIM(temp.BusinessFunction))  and BF.AttributeName = 'Business Function'
	Left join #DropdownTemp OC on  LTRIM(RTRIM(OC.AttributeValueName)) = LTRIM(RTRIM(temp.OperationallyCritical)) and OC.AttributeName = 'Operationally Critical'
	Left join #DropdownTemp SC on  LTRIM(RTRIM(SC.AttributeValueName)) = LTRIM(RTRIM(temp.SecurityCritical)) and SC.AttributeName = 'Security Critical'
	Left join #DropdownTemp HT on  LTRIM(RTRIM(HT.AttributeValueName)) = LTRIM(RTRIM(temp.HighTouch)) and HT.AttributeName = 'HighTouch'
	LEFT join #DropdownTemp SL on  LTRIM(RTRIM(SL.AttributeValueName)) = LTRIM(RTRIM(temp.SLALevel)) and SL.AttributeName = 'SLA Level'
	where tra.ApplicationId = @appid and tra.isDeleted = 0
	END
	
	-----------New app ----------
	else
	begin
	insert into [PP].Transition_AppInventroyAttributes (ApplicationId,CustomerId,EsaProjectId,
	[KTNeeded] ,
	[LanguageRequirements],
	[WaveorCluster],
	[ApplicationOwnerIT],
	[CRType],
	[HardwareSoftwareRequirement],
	[BusinessFunction],
	[OperationallyCritical],
	[SecurityCritical],
	[HighTouch],
	[PriceperMonth],
	[SLALevel],
	[VendorTypeName],
	[VendorName],
	[OtherVendorTypeName],isDeleted,CreatedBy,CreatedDate)

	select @appid,@customerId,@ProjectID,
	KT.ID as KTNeeded,
	temp.[LanguageRequirements],
	temp.[WaveOrCluster],temp.[ApplicationOwnerIT],
	CR.ID as CRType,
	temp.[HardwareSoftwareRequirements],
	BF.ID as [BusinessFunction],
	OC.ID as [OperationallyCritical],
	SC.ID as [SecurityCritical],
	HT.ID as [HighTouch],
	temp.[PricePerMonth],
	SL.ID as [SLALevel],
	temp.[VendorTypeName],temp.[VendorName],temp.[OtherVendorTypeName], 
	0 as isDeleted, @CognizantId as CreatedBy, 
	getdate() as CreatedDate
	from @TVP_AppInventoryUploadTransition temp
	join avl.APP_MAS_ApplicationDetails(nolock) a on LTRIM(RTRIM(a.ApplicationName))  = LTRIM(RTRIM(temp.ApplicationName))
	Left join #DropdownTemp KT on  LTRIM(RTRIM(KT.AttributeValueName)) = LTRIM(RTRIM(temp.KTNeeded)) and KT.AttributeName = 'KTNeeded'
	Left join #DropdownTemp CR on  LTRIM(RTRIM(CR.AttributeValueName)) = LTRIM(RTRIM(temp.CRType)) and CR.AttributeName = 'CRType'
	Left join #DropdownTemp BF on  LTRIM(RTRIM(BF.AttributeValueName)) = LTRIM(RTRIM(temp.BusinessFunction))  and BF.AttributeName = 'Business Function'
	Left join #DropdownTemp OC on  LTRIM(RTRIM(OC.AttributeValueName)) = LTRIM(RTRIM(temp.OperationallyCritical)) and OC.AttributeName = 'Operationally Critical'
	Left join #DropdownTemp SC on  LTRIM(RTRIM(SC.AttributeValueName)) = LTRIM(RTRIM(temp.SecurityCritical)) and SC.AttributeName = 'Security Critical'
	Left join #DropdownTemp HT on  LTRIM(RTRIM(HT.AttributeValueName)) = LTRIM(RTRIM(temp.HighTouch)) and HT.AttributeName = 'HighTouch'
	LEFT join #DropdownTemp SL on  LTRIM(RTRIM(SL.AttributeValueName)) = LTRIM(RTRIM(temp.SLALevel)) and SL.AttributeName = 'SLA Level'
	where temp.ApplicationName != '' and a.applicationId = @appid
	END
	Drop TABLE #Existingapp
	DROP table #DropdownTemp 
	
COMMIT TRAN
END TRY
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[PP].[SaveAppInvTransitionAttributesBasedonApplication]', @ErrorMessage, 0,@customerId
		
	END CATCH  
END
