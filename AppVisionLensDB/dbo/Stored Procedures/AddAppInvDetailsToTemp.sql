/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE PROCEDURE [dbo].[AddAppInvDetailsToTemp]
	 @CustomerId int =null,
	 @isCognizant int =null,
	 @TVP_AppInventoryUpload TVP_AppInventoryApplicationDetailsUpload READONLY  
AS
BEGIN
BEGIN TRY
BEGIN TRAN
	
	SET NOCOUNT ON;
	TRUNCATE TABLE MAS.AppInventoryUpload
   INSERT INTO MAS.AppInventoryUpload(   
	[ApplicationName],
	[ApplicationCode],
	[ApplicationShortName],
	[BusinessClusterName],
	[CodeOwnerShip],
	[BusinessCriticalityName],
	[PrimaryTechnologyName],
	[ProductMarketName],
	[ApplicationDescription],
	[ApplicationCommisionDate],
	[RegulatoryCompliantName],
	[DebtcontrolScopeName],
	[UserBase],
	[SupportWindowName],
	[Incallwdgreen],
	[Infraallwdgreen],
	[Incallwdamber],
	[Infraallwdamber],
	[Infoallwdamber],
	[Infoallwdgreen],
	[SupportCategoryName],
	[OperatingSystem],
	[ServerConfiguration],
	[ServerOwner],
	[LicenseDetails],
	[DatabaseVersion],
	[HostedEnvironmentName],
	[CloudServiceProvider],
	[CloudModel],
	[Active],
	[isCognizant],
	[CustomerId],
	[IsValid],
	[OtherTechnology],
	[OtherServiceProvider],
	[OtherWindow]
	)
	SELECT
	[ApplicationName],
	[ApplicationCode],
	[ApplicationShortName],
	[BusinessClusterName],
	[CodeOwnerShip],
	[BusinessCriticalityName],
	[PrimaryTechnologyName],
	[ProductMarketName],
	[ApplicationDescription],
	[ApplicationCommisionDate],
	[RegulatoryCompliantName],
	[DebtcontrolScopeName],
	[UserBase],
	[SupportWindowName],
	[Incallwdgreen],
	[Infraallwdgreen],
	[Incallwdamber],
	[Infraallwdamber],
	[Infoallwdamber],
	[Infoallwdgreen],
	[SupportCategoryName],
	[OperatingSystem],
	[ServerConfiguration],
	[ServerOwner],
	[LicenseDetails],
	[DatabaseVersion],
	[HostedEnvironmentName],
	[CloudServiceProvider],
	[CloudModel],
	[Active],
	@isCognizant,
	[CustomerId],
	[IsValid],
	CONVERT(NVARCHAR(50),LTRIM(RTRIM([OtherTechnology]))) AS OtherTechnology,
	CONVERT(NVARCHAR(50),LTRIM(RTRIM([OtherServiceProvider]))) AS OtherServiceProvider,
	CONVERT(NVARCHAR(5),LTRIM(RTRIM([OtherWindow]))) AS OtherWindow
	From  @TVP_AppInventoryUpload

	select a.ApplicationID
	into #app 
	from avl.APP_MAS_ApplicationDetails a join avl.BusinessClusterMapping b on a.SubBusinessClusterMapID=b.BusinessClusterMapID 
	and b.IsHavingSubBusinesss='0' 
		where CustomerID=@CustomerId 

	
update avl.APP_MAS_ApplicationDetails set SubBusinessClusterMapID=c.BusinessClusterMapID,ApplicationCode=b.ApplicationCode,ApplicationShortName=b.ApplicationShortName
,CodeOwnerShip=e.ApplicationTypeID,BusinessCriticalityID=f.BusinessCriticalityID,PrimaryTechnologyID=g.PrimaryTechnologyID,ApplicationDescription=b.ApplicationDescription,
ProductMarketName=b.ProductMarketName,ApplicationCommisionDate=b.ApplicationCommisionDate,RegulatoryCompliantID=h.RegulatoryCompliantID,DebtControlScopeID=i.DebtcontrolScopeID,
OtherPrimaryTechnology=b.OtherTechnology,
IsActive=  CASE 
    WHEN LOWER( b.Active) ='yes'  THEN 1
	when  LOWER(b.Active) ='no'  THEN 0
	END
from avl.APP_MAS_ApplicationDetails a join mas.AppInventoryUpload b on a.ApplicationName=b.ApplicationName
join avl.BusinessClusterMapping c on b.BusinessClusterName=c.BusinessClusterBaseName and IsHavingSubBusinesss='0' 
join #app d on d.ApplicationID=a.ApplicationID
join avl.APP_MAS_OwnershipDetails e on b.CodeOwnerShip=e.ApplicationTypename
join avl.APP_MAS_BusinessCriticality f on b.BusinessCriticalityName=f.BusinessCriticalityName 
join avl.APP_MAS_PrimaryTechnology g on b.PrimaryTechnologyName=g.PrimaryTechnologyName
join avl.APP_MAS_RegulatoryCompliant h on h.RegulatoryCompliantName=b.RegulatoryCompliantName 
join avl.APP_MAS_DebtcontrolScope i on i.DebtcontrolScopeName=b.DebtcontrolScopeName
 where c.CustomerID=@CustomerId
 and c.IsDeleted='0' 
 and a.ApplicationID in (select ApplicationID from #app )

 
 

SET NOCOUNT OFF;

COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[AddAppInvDetailsToTemp] ', @ErrorMessage, 0,@CustomerId
		
	END CATCH  




END
