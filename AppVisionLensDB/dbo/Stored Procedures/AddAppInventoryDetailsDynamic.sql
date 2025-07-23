/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/



CREATE PROCEDURE [dbo].[AddAppInventoryDetailsDynamic] 
	@CognizantId int =null,
	@CustomerId int=Null
AS
BEGIN
BEGIN TRY
BEGIN TRAN
	
	SET NOCOUNT ON;
	--select * from mas.AppInventoryUpload
    
IF OBJECT_ID('tempdb..#tempT') IS NOT NULL DROP TABLE #tempT 
CREATE TABLE #Temp
(
ApplicationID BIGINT NULL
,ApplicationName nVARCHAR(100) NULL	
,ApplicationCode nVARCHAR(50) NULL	
,ApplicationShortName nVARCHAR(8) NULL	
,SubBusinessClusterMapID BIGINT NULL
,SubBusinessClusterName nVARCHAR(50) NULL		
,ApplicationTypeID   BIGINT NULL   --CodeOwnerShip
,ApplicationTypename nVARCHAR(50) NULL
,BusinessCriticalityID	BigINT NULL
,BusinessCriticalityName VARCHAR(max) NULL
,PrimaryTechnologyID BIGINT NULL
,PrimaryTechnologyName VARCHAR(max) NULL
,ApplicationDescription nVARCHAR(200) NULL
,ProductMarketName	nVARCHAR(max) NULL
,ApplicationCommisionDate DATETIME	
,RegulatoryCompliantID BIGINT NULL
,RegulatoryCompliantName VARCHAR(MAX) NULL
,DebtControlScopeID	BIGINT NULL
,DebtcontrolScopeName VARCHAR(max) NULL
,UserBase nVARCHAR(50) NULL
,SupportWindowID BIGINT NULL
,SupportWindowName VARCHAR(max) NULL
,[Incallwdgreen] NVARCHAR(50) NULL
,[Infraallwdgreen] NVARCHAR(50) NULL
,[Infoallwdgreen] NVARCHAR(50) NULL
,[Incallwdamber] NVARCHAR(50) NULL
,[Infraallwdamber] NVARCHAR(50) NULL
,[Infoallwdamber] NVARCHAR(50) NULL
,[SupportCategoryID] BIGINT NULL
,SupportCategoryName VARCHAR(max) NULL
,[ProcessingTypeID] BigINT NULL
,ProcessingTypeName VARCHAR(max) NULL
,[VMName] nVARCHAR(100) NULL
,[OperatingSystem] nVARCHAR(100) NULL
,[ServerConfiguration] nVARCHAR(100) NULL
,[ServerOwner] nVARCHAR(100) NULL
,[LicenseDetails] nVARCHAR(100) NULL
,[DatabaseVersion] nVARCHAR(100) NULL
,[HostedEnvironmentID] BIGINT NULL
,HostedEnvironmentName VARCHAR(max) NULL
,CloudServiceProviderID BIGINT NULL
,CloudServiceProvider VARCHAR(max) NULL
,CloudModelName NVARCHAR(20) NULL
,CloudModelID INT NULL
,[AppPlatform] NVARCHAR(1000) NULL
,CustomerId VARCHAR(250) NULL
,[isCognizant] INT NULL
,IsActive INT  NULL
,OtherTechnology NVARCHAR(50)
,OtherServiceProvider NVARCHAR(50)
,OtherWindow NVARCHAR(5)
)

INSERT INTO #Temp
(
ApplicationName
,ApplicationCode 
,ApplicationShortName 
,SubBusinessClusterName
,ApplicationTypename --CodeOwnerShip
,BusinessCriticalityName
,PrimaryTechnologyName
,ProductMarketName	
,ApplicationDescription 
,ApplicationCommisionDate
,RegulatoryCompliantName 
,DebtcontrolScopeName 
,UserBase
,SupportWindowName 
,[Incallwdgreen]
,[Infraallwdgreen]
,[Incallwdamber]
,[Infraallwdamber]
,[Infoallwdamber]
,[Infoallwdgreen]
,SupportCategoryName
,[ProcessingTypeID]
,ProcessingTypeName
,[VMName]
,[OperatingSystem] 
,[ServerConfiguration] 
,[ServerOwner] 
,[LicenseDetails] 
,[DatabaseVersion]
,HostedEnvironmentName 
,CloudServiceProvider
,CloudModelName
,[AppPlatform]
,CustomerId
,[isCognizant]
,IsActive
,OtherTechnology
,OtherServiceProvider
,OtherWindow
)
SELECT DISTINCT
[ApplicationName],
	[ApplicationCode],
	[ApplicationShortName],
	BusinessClusterName,
	[CodeOwnerShip],
	[BusinessCriticalityName],
	[PrimaryTechnologyName],
	[ProductMarketName],
	[ApplicationDescription],
	[ApplicationCommisionDate],
	[RegulatoryCompliantName],	
	ISNULL(DebtcontrolScopeName,'No') AS [DebtcontrolScopeName],
	[UserBase],
	[SupportWindowName],
	[Incallwdgreen],
	[Infraallwdgreen],
	[Incallwdamber],
	[Infraallwdamber],
	[Infoallwdamber],
	[Infoallwdgreen],
	[SupportCategoryName],
	NULL,
	NULL,
	NULL,
	[OperatingSystem],
	[ServerConfiguration],
	[ServerOwner],
	[LicenseDetails],
	[DatabaseVersion],
	[HostedEnvironmentName],
	[CloudServiceprovider],
	[CloudModel],
	NULL,
	[CustomerId],
	[isCognizant],
	CASE WHEN Active='Yes' THEN 1 ELSE 0 END Active,
	OtherTechnology,
	OtherServiceProvider,
	OtherWindow
FROM MAS.AppInventoryUpload 

select a.ApplicationID
	into #app1 
	from avl.APP_MAS_ApplicationDetails a join avl.BusinessClusterMapping b on a.SubBusinessClusterMapID=b.BusinessClusterMapID 
	and b.IsHavingSubBusinesss='0' 
		where CustomerID=@CustomerId 

SELECT 'SubBusinessClusterMapID'

--SubBusinessClusterMapID
UPDATE A SET A.SubBusinessClusterMapID=BCM.BusinessClusterMapID
FROM #Temp A INNER JOIN AVL.BusinessClusterMapping BCM
ON A.SubBusinessClusterName=BCM.BusinessClusterBaseName 
WHERE BCM.IsHavingSubBusinesss=0 AND A.CustomerId =BCM.CustomerID
SELECT 'ApplicationTypeID'

--ApplicationTypeID
UPDATE A SET A.ApplicationTypeID=C.ApplicationTypeID
FROM #Temp A INNER JOIN AVL.APP_MAS_OwnershipDetails C
ON A.ApplicationTypename=C.ApplicationTypename 
WHERE A.CustomerId=@CustomerId 

SELECT 'BusinessCriticalityID'
--BusinessCriticalityID
UPDATE A SET A.BusinessCriticalityID=D.BusinessCriticalityID
FROM #Temp A INNER JOIN AVL.APP_MAS_BusinessCriticality D 
ON A.BusinessCriticalityName=D.BusinessCriticalityName 
WHERE A.CustomerId=@CustomerId

SELECT 'PrimaryTechnologyID'
--PrimaryTechnologyID
UPDATE A SET A.PrimaryTechnologyID=E.PrimaryTechnologyID
FROM #Temp A INNER JOIN AVL.APP_MAS_PrimaryTechnology E
ON A.PrimaryTechnologyName=E.PrimaryTechnologyName
WHERE A.CustomerId=@CustomerId

SELECT 'RegulatoryCompliantID'
--RegulatoryCompliantID
UPDATE A SET A.RegulatoryCompliantID=F.RegulatoryCompliantID
FROM #Temp A INNER JOIN AVL.APP_MAS_RegulatoryCompliant F
ON A.RegulatoryCompliantName=F.RegulatoryCompliantName 
WHERE A.CustomerId=@CustomerId

select 'DebtControlScopeID'
--DebtControlScopeID
UPDATE A SET A.DebtControlScopeID=G.DebtcontrolScopeID
FROM #Temp A INNER JOIN AVL.APP_MAS_DebtcontrolScope G
ON A.DebtcontrolScopeName=G.DebtcontrolScopeName 
WHERE A.CustomerId=@CustomerId

select 'SupportWindowID'
--SupportWindowID
UPDATE A SET A.SupportWindowID=H.SupportWindowID
FROM #Temp A INNER JOIN AVL.APP_MAS_SupportWindow H
ON A.SupportWindowName=H.SupportWindowName 
WHERE A.CustomerId=@CustomerId

select 'SupportCategoryID'
--SupportCategoryID
UPDATE A SET A.SupportCategoryID=I.SupportCategoryID
FROM #Temp A INNER JOIN AVL.APP_MAS_SupportCategory I
ON A.SupportCategoryName=I.SupportCategoryName 
WHERE A.CustomerId=@CustomerId

select 'HostedEnvironmentID'
--HostedEnvironmentID
UPDATE A SET A.HostedEnvironmentID=J.HostedEnvironmentID
FROM #Temp A INNER JOIN AVL.APP_MAS_HostedEnvironment J
ON A.HostedEnvironmentName=J.HostedEnvironmentName 
WHERE A.CustomerId=@CustomerId

select 'CloudServiceProviderID'
UPDATE A SET A.CloudServiceProviderID=J.CloudServiceProviderID
FROM #Temp A INNER JOIN AVL.APP_MAS_CloudServiceProvider J
ON A.CloudServiceProvider=J.CloudServiceProviderName 
WHERE A.CustomerId=@CustomerId

UPDATE A SET A.CloudModelID=J.CloudModelID
FROM #Temp A INNER JOIN MAS.MAS_CloudModelProvider J
ON A.CloudModelName=J.CloudModelName 
WHERE A.CustomerId=@CustomerId

select t.ApplicationID, t.ApplicationName
	,t.ApplicationCode,t.ApplicationShortName,t.SubBusinessClusterMapID,t.SubBusinessClusterName,t.ApplicationTypeID,t.ApplicationTypename,
	t.BusinessCriticalityID,t.BusinessCriticalityName,t.PrimaryTechnologyID,t.PrimaryTechnologyName,t.ApplicationDescription,
	t.ProductMarketName,t.ApplicationCommisionDate,t.RegulatoryCompliantID,t.RegulatoryCompliantName,
	t.DebtControlScopeID,t.DebtcontrolScopeName,t.UserBase,t.SupportWindowID,t.SupportWindowName,
	t.Incallwdgreen,t.Infraallwdgreen,t.Infoallwdgreen,t.Incallwdamber,t.Infraallwdamber,t.Infoallwdamber,
	t.SupportCategoryID,t.SupportCategoryName,t.ProcessingTypeID,t.ProcessingTypeName,t.VMName,t.OperatingSystem,
	t.ServerConfiguration,t.ServerOwner,t.LicenseDetails,t.DatabaseVersion,t.HostedEnvironmentID,t.HostedEnvironmentName,
	t.CloudServiceProviderID,t.CloudServiceProvider,
	t.CloudModelName,t.CloudModelID,
	t.AppPlatform,t.CustomerId,t.isCognizant,t.IsActive,t.OtherTechnology,t.OtherServiceProvider,t.OtherWindow
into #existingAppDetails 
from #Temp t 
join avl.APP_MAS_ApplicationDetails mas 
	on t.ApplicationName=mas.ApplicationName 
	and t.SubBusinessClusterMapID=mas.SubBusinessClusterMapID join avl.BusinessClusterMapping bcm on bcm.CustomerID=@CustomerId
	

select * into #newAppDetails from(
select * from #Temp
EXCEPT
select * from #existingAppDetails)new;

		Update APD SET 
		APD.ApplicationCode=T.ApplicationCode,
		APD.ApplicationShortName=T.ApplicationShortName
		,APD.CodeOwnerShip=T.ApplicationTypeID
		,APD.BusinessCriticalityID=T.BusinessCriticalityID
		,APD.PrimaryTechnologyID=T.PrimaryTechnologyID
		,APD.ApplicationDescription=T.ApplicationDescription
		,APD.ProductMarketName=T.ProductMarketName
		,APD.ApplicationCommisionDate=T.ApplicationCommisionDate
		,APD.RegulatoryCompliantID=T.RegulatoryCompliantID
		,APD.DebtControlScopeID=T.DebtControlScopeID
		,APD.ModifiedBy=@CognizantId
		,APD.ModifiedDate=GETDATE()
		,APD.OtherPrimaryTechnology=T.OtherTechnology
		FROM #existingAppDetails T INNER JOIN AVL.APP_MAS_ApplicationDetails APD
		ON T.ApplicationName=APD.ApplicationName 
		join #app1 x on APD.ApplicationID=x.ApplicationID




		UPDATE ExAPD SET
		ExAPD.UserBase=T.UserBase
		,ExAPD.SupportWindowID=T.SupportWindowID
		,ExAPD.Incallwdgreen=T.Incallwdgreen
		,ExAPD.Infraallwdgreen=T.Infraallwdgreen
		,ExAPD.Infoallwdgreen=T.Infoallwdgreen
		,ExAPD.Incallwdamber=T.Incallwdamber
		,ExAPD.Infraallwdamber=T.Infraallwdamber
		,ExAPD.Infoallwdamber=T.Infoallwdamber
		,ExAPD.SupportCategoryID=T.SupportCategoryID
		,ExAPD.ProcessingTypeID=NULL
		,ExAPD.ModifiedBy=@CognizantId	
		,ExAPD.ModifiedDate=GETDATE()
		,ExAPD.OtherSupportWindow=T.OtherWindow
		FROM #existingAppDetails T INNER JOIN AVL.APP_MAS_ApplicationDetails AD
		ON T.ApplicationName=AD.ApplicationName AND T.SubBusinessClusterMapID=AD.SubBusinessClusterMapID
		INNER JOIN	AVL.APP_MAS_Extended_ApplicationDetail ExAPD
		ON AD.ApplicationID=ExAPD.ApplicationID 


		UPDATE Inf SET
		Inf.VMName=NULL
		,Inf.OperatingSystem=T.OperatingSystem
		,Inf.ServerConfiguration=T.ServerConfiguration
		,Inf.ServerOwner=T.ServerOwner
		,Inf.LicenseDetails=T.LicenseDetails
		,Inf.DatabaseVersion=T.DatabaseVersion
		,Inf.HostedEnvironmentID=T.HostedEnvironmentID
		,Inf.CloudServiceProvider=T.CloudServiceProviderID
		,Inf.CloudModelID= T.CloudModelID
		,Inf.AppPlatform=NULL
		,Inf.IsDeleted=0
		,Inf.ModifiedBy=@CognizantId	
		,Inf.ModifiedDate=GETDATE()
		,Inf.OtherCloudServiceProvider=T.OtherServiceProvider
		FROM #existingAppDetails T INNER JOIN AVL.APP_MAS_ApplicationDetails AD
		ON T.ApplicationName=AD.ApplicationName AND T.SubBusinessClusterMapID=AD.SubBusinessClusterMapID
		INNER JOIN AVL.APP_MAS_InfrastructureApplication Inf
		ON AD.ApplicationID=Inf.ApplicationID 

		--- Appliction ISActive Update
		
		UPDATE AD SET	AD.IsActive = EA.IsActive ,
						AD.ModifiedBy = @CognizantId,
						AD.ModifiedDate = GETDATE()
		FROM AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
		JOIN #existingAppDetails EA
			ON EA.ApplicationName=AD.ApplicationName
		JOIN AVL.BusinessClusterMapping(nolock) BC
			ON AD.SubBusinessClusterMapID=BC.BusinessClusterMapID 
		WHERE BC.CustomerID=@CustomerId 
		
		--- Inactivating Application Project mapping
		UPDATE AM SET AM.IsDeleted = CASE WHEN EA.IsActive=0 THEN 1 ELSE 0 END 
		FROM  AVL.APP_MAP_ApplicationProjectMapping (NOLOCK) AM			
		JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
			ON AD.ApplicationID=AM.ApplicationID
		JOIN #existingAppDetails(NOLOCK) EA
			ON EA.ApplicationName=AD.ApplicationName
		JOIN avl.MAS_ProjectMaster(NOLOCK) PM
			ON PM.ProjectID=AM.ProjectID 	
		WHERE   PM.CustomerID=@CustomerId
				
DECLARE @projectCount bigint;
SELECT 
		@projectCount=  count (distinct ECPRBM.ProjectId)
		 FROM 
		 [AVL].[VW_EmployeeCustomerProjectRoleBUMapping] ECPRBM 
		JOIN
				AVl.MAS_ProjectMaster PM ON PM.ProjectID=ECPRBM.ProjectId
		WHERE 
				ECPRBM.CustomerId=@CustomerId AND PM.CustomerID=@CustomerId AND PM.IsDeleted=0

/******************/

	DECLARE @Count int 
	Set @Count= (SELECT COUNT(*) FROM #newAppDetails)
	
		/***PROGRESS****/
IF @Count>0
BEGIN
IF EXISTS(
			SELECT 
					1 
			FROM 
					AVL.PRJ_ConfigurationProgress 
			WHERE 
					ScreenID=1 AND CustomerID=@CustomerID)
BEGIN
IF NOT EXISTS(
SELECT 1 FROM AVL.APP_MAS_ApplicationDetails AD JOIN Avl.BusinessClusterMapping BC 
ON BC.BusinessClusterMapID=AD.SubBusinessClusterMapID where BC.CustomerID=@CustomerID AND BC.IsDeleted=0
)
	BEGIN
	UPDATE AVL.PRJ_ConfigurationProgress SET CompletionPercentage=75,
	ModifiedBy=@CognizantId,
	ModifiedDate=GETDATE()
	WHERE CustomerID=@CustomerID AND ScreenID=1
	END

	END
	END

/***PROGRESS****/	

	WHILE (@Count>0)
	BEGIN
	
	select * into #AppInvtopTemp FROM(SELECT top 1 * from #newAppDetails) A

	---select * from #AppInvtopTemp
		INSERT INTO AVL.APP_MAS_ApplicationDetails
		(
		ApplicationName	
		,ApplicationCode	
		,ApplicationShortName	
		,SubBusinessClusterMapID	
		,CodeOwnerShip	
		,BusinessCriticalityID	
		,PrimaryTechnologyID	
		,ApplicationDescription	
		,ProductMarketName	
		,ApplicationCommisionDate	
		,RegulatoryCompliantID	
		,DebtControlScopeID	
		,IsActive	
		,CreatedBy	
		,CreatedDate	
		,ModifiedBy	
		,ModifiedDate
		,OtherPrimaryTechnology

		)
		SELECT DISTINCT
		ApplicationName
		,ApplicationCode 
		,ApplicationShortName 
		,SubBusinessClusterMapID
		,ApplicationTypeID --CodeOwnerShip
		,BusinessCriticalityID
		,PrimaryTechnologyID
		,ApplicationDescription
		,ProductMarketName		 
		,ApplicationCommisionDate
		,RegulatoryCompliantID
		,isnull(DebtControlScopeID,0)
		,1
		,@CognizantId
		--,575633
		,Getdate()
		,NULL
		,NULL
		,OtherTechnology
		from #AppInvtopTemp 	
		
		
		DECLARE @ApplicationID BigINT
		DECLARE @ApplicationName VARCHAR(MAX)

	SET @ApplicationID=(SELECT @@IDENTITY)
	SET @ApplicationName=(SELECT TOP 1 ApplicationName FROM #newAppDetails)
	

UPDATE A SET A.ApplicationID=@ApplicationID
FROM #AppInvtopTemp A 
WHERE A.CustomerId=@CustomerId AND A.ApplicationName=@ApplicationName
/*projectmapping***/
DECLARE @ProjectID bigint;
IF @projectCount=1
BEGIN
---DECLARE @ProjectID bigint;
SELECT 
		TOP 1 @ProjectID=PM.ProjectID
		 FROM 
		 [AVL].[VW_EmployeeCustomerProjectRoleBUMapping] ECPRBM 
		JOIN
				AVl.MAS_ProjectMaster PM ON	PM.ProjectID=ECPRBM.ProjectId
		WHERE 
				ECPRBM.CustomerId=@CustomerId AND PM.CustomerID=@CustomerId AND PM.IsDeleted=0

				

IF NOT EXISTS(SELECT 1 FROM AVL.APP_MAP_ApplicationProjectMapping AP WHERE AP.ProjectID=@ProjectID and AP.ApplicationID=@ApplicationID)
BEGIN
INSERT 
				INTO 
						AVL.APP_MAP_ApplicationProjectMapping 
						(
						ProjectID
						,ApplicationID
						,IsDeleted
						,CreatedBy
						,CreatedDate)
						VALUES
						(
						@ProjectID,
						@ApplicationID,
						0,
						@CognizantId,
						GETDATE()
						);
	
END
END

/***project mapping*****/
--Insert for Extended_ApplicationDetail
		Insert into AVL.APP_MAS_Extended_ApplicationDetail
		(
		[ApplicationID]
		,[UserBase]
		,[SupportWindowID]
		,[Incallwdgreen]
		,[Infraallwdgreen]
		,[Infoallwdgreen]
		,[Incallwdamber]
		,[Infraallwdamber]
		,[Infoallwdamber]
		,[SupportCategoryID]
		,[ProcessingTypeID]
		,[CreatedBy]
		,[CreatedDate]
		,[ModifiedBy]
		,[ModifiedDate]
		,OtherSupportWindow
		)
		select DISTINCT
		ApplicationID
		,UserBase
		,SupportWindowID
		,[Incallwdgreen]		
		,[Infraallwdgreen]
		,[Infoallwdgreen]
		,[Incallwdamber]
		,[Infraallwdamber]
		,[Infoallwdamber]
		,SupportCategoryID
		,NULL
		,@CognizantId	
		,Getdate()
		,NULL
		,NULL
		,OtherWindow
		from #AppInvtopTemp
		
		

--Insert for AVL.APP_MAS_InfrastructureApplication
	Insert INTO AVL.APP_MAS_InfrastructureApplication
	(
		[ApplicationID]
		,[VMName]
		,[OperatingSystem]
		,[ServerConfiguration]
		,[ServerOwner]
		,[LicenseDetails]
		,[DatabaseVersion]
		,[HostedEnvironmentID]
		,[CloudServiceProvider]
		,[CloudModelID]
		,[AppPlatform]
		,[IsDeleted]
		,[CreatedBy]
		,[CreatedDate]
		,[ModifiedBy]
		,[ModifiedDate]
		,OtherCloudServiceProvider
	)
	select DISTINCT
	  ApplicationID
	 , NULL
	 ,[OperatingSystem] 
	 ,[ServerConfiguration]
	 ,[ServerOwner]
	 ,[LicenseDetails]
	 ,[DatabaseVersion]
	 ,[HostedEnvironmentID]
	 ,[CloudServiceProviderID]
	 ,CloudModelID
	 ,NULL
	 ,0
	 ,@CognizantId
	 ,Getdate()
	 ,NULL
	 ,NULL
	 ,OtherServiceProvider
	from #AppInvtopTemp ;
	


	WITH  q AS
        (
        SELECT TOP 1 *
        FROM #newAppDetails
		)
    
DELETE
FROM q
DROP TABLE #AppInvtopTemp



SET @ApplicationID=NULL
SET @ApplicationName=NULL	
Set @Count=@Count-1

END
	
	DROP TABLE #Temp
	DROP table #existingAppDetails
	Drop TABLE #newAppDetails
	
	COMMIT TRAN
	END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[AddAppInventoryDetailsDynamic] ', @ErrorMessage, 0,@CustomerId
		
	END CATCH  

END
