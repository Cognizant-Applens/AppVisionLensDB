CREATE PROCEDURE [dbo].[AddAppInvDetailsToTemp_Customer]
	 @CustomerId int =null,
	 @isCognizant int =null,
	 @TVP_AppInventoryUpload [TVP_AppInventoryApplicationDetailsUpload_Customer] READONLY  
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
	ISNULL(DebtcontrolScopeName,'') AS [DebtcontrolScopeName],
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
	   	 	

	TRUNCATE TABLE [ADM].[AppInventoryCognizant_Upload]
	INSERT INTO [ADM].[AppInventoryCognizant_Upload]
           ([ApplicationName]
           ,[ApplicationScope]
           ,[IsRevenue]
           ,[IsAnySIVendor]
           ,[GeographiesSupported]
           ,[FunctionalKnowledge]
           ,[ExecutionMethod]
           ,[OtherExecutionMethod]
           ,[SourceCodeAvailability]
           ,[RegulatoryBody]
           ,[OtherRegulatoryBody]
           ,[IsAppAvailable]
           ,[AvailabilityPercent]
		   ,[IsCognizant]
		   ,[CustomerId] 
		   ,[IsValid]	
           ,[IsDeleted]
           ,[CreatedBy]
           ,[CreatedDate]
           )

		SELECT 
			[ApplicationName]
           ,[ApplicationScope]
           ,[IsRevenue]
           --,[IsAnySIVendor]
		   ,NULL
           ,[GeographiesSupported]
           ,[FunctionalKnowledge]
           ,[ExecutionMethod]
           ,[OtherExecutionMethod]
           ,[SourceCodeAvailability]
           ,[RegulatoryBody]
           ,[OtherRegulatoryBody]
           ,[IsAppAvailable]
           ,[AvailabilityPercent]
			,@isCognizant
			,[CustomerId]
			,[IsValid]	
			,0
			,'System'
			,GETDATE()
		FROM @TVP_AppInventoryUpload

	select a.ApplicationID,a.ApplicationName
	into #app 
	from avl.APP_MAS_ApplicationDetails a 
	join avl.BusinessClusterMapping b on a.SubBusinessClusterMapID=b.BusinessClusterMapID 
	and b.IsHavingSubBusinesss='0' 
		where b.CustomerID=@CustomerId 


	TRUNCATE TABLE [ADM].[AppInventoryUnitTestingCognizant_Upload]
	INSERT INTO [ADM].[AppInventoryUnitTestingCognizant_Upload]
           (ApplicationName
			,NFRCaptured
			,IsUnitTestAutomated
			,UnitTestFrameworkID
			,OtherUnitTestFramework
			,TestingCoverage
			,IsRegressionTest
			,RegressionTestCoverage
			,IsCognizant
			,CustomerId
			,IsValid
			,IsDeleted
			,CreatedBy
			,CreatedDate
           )
		SELECT 
			ApplicationName
			,NFRCaptured
			,IsUnitTestAutomated
			,UnitTestFrameworkID
			,OtherUnitTestFramework
			,TestingCoverage
			,IsRegressionTest
			,RegressionTestCoverage
			,@isCognizant
			,[CustomerId]
			,[IsValid]	
			,0
			,'System'
			,GETDATE()
		FROM @TVP_AppInventoryUpload
		--select * from [TVP_AppInventoryApplicationDetailsUpload_Cognizant] 
	
update avl.APP_MAS_ApplicationDetails set SubBusinessClusterMapID=c.BusinessClusterMapID,ApplicationCode=b.ApplicationCode,ApplicationShortName=b.ApplicationShortName
,CodeOwnerShip=e.ApplicationTypeID,BusinessCriticalityID=f.BusinessCriticalityID,PrimaryTechnologyID=g.PrimaryTechnologyID,ApplicationDescription=b.ApplicationDescription,
ProductMarketName=b.ProductMarketName,ApplicationCommisionDate=b.ApplicationCommisionDate,RegulatoryCompliantID=h.RegulatoryCompliantID,
DebtControlScopeID= CASE 
    WHEN LOWER( b.DebtcontrolScopeName) ='yes'  THEN 1
	when  LOWER(b.DebtcontrolScopeName) ='no'  THEN 2
	when  LOWER(b.DebtcontrolScopeName) =''  THEN NULL
	END,
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


 UPDATE  a SET 
      --a.[ApplicationScope] = b.[ApplicationScope]
      a.[IsRevenue] =CASE 
    WHEN LOWER( b.IsRevenue) ='yes'  THEN 1
	when  LOWER(b.IsRevenue) ='no'  THEN 0 END
      ,a.[IsAnySIVendor] =NULL
	--  CASE 
 --   WHEN LOWER( b.IsAnySIVendor) ='yes'  THEN 1
	--when  LOWER(b.IsAnySIVendor) ='no'  THEN 0 END
	  
      --,a.[GeographiesSupported] = b.GeographiesSupported
      ,a.[FunctionalKnowledge] = F.ID
      ,a.[ExecutionMethod] = EM.ID
      ,a.[OtherExecutionMethod] =b.OtherExecutionMethod
      ,a.[SourceCodeAvailability] = SC.ID
     -- ,a.[RegulatoryBody] = b.RegulatoryBody
      ,a.[OtherRegulatoryBody] = b.otherRegulatoryBody
      ,a.[IsAppAvailable] = CASE 
      WHEN LOWER( b.IsAppAvailable) ='yes'  THEN 1
	  when  LOWER(b.IsAppAvailable) ='no'  THEN 0
	  when  LOWER(b.IsAppAvailable) ='na'  THEN 2 END
      ,a.[AvailabilityPercentage] = b.AvailabilityPercent
      ,a.[IsDeleted] = b.IsDeleted      
      ,a.[ModifiedBy] = 'System'
      ,a.[ModifiedDate] = GETDATE()
 
 from ADM.ALMApplicationDetails a 
 join #app d on a.ApplicationID=d.ApplicationID 
 join [ADM].[AppInventoryCognizant_Upload] b on d.ApplicationName=b.ApplicationName
 LEFT JOIN ADM.FunctionalKnowledge F on b.FunctionalKnowledge=F.FunctionalKnowledgeName AND F.isdeleted=0
 --LEFT JOIN [ADM].[ExecutionMethod] EM on b.ExecutionMethod=EM.ExecutionMethodName AND EM.isdeleted=0
 LEFT JOIN (SELECT PPA.AttributeValueID AS ID, PPA.AttributeValueName AS ExecutionMethodName from Mas.PPAttributeValues (NOLOCK) PPA
			 INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0
			 WHERE AttributeName = 'ExecutionMethod') EM on b.ExecutionMethod=EM.ExecutionMethodName
 LEFT JOIN [ADM].[SourceCodeAvailability] SC on B.SourceCodeAvailability=SC.[SourceCodeName] AND SC.IsDeleted=0

 where b.CustomerID=@CustomerId
 and a.IsDeleted='0' 
 and a.ApplicationID in (select ApplicationID from #app )

 -- Application Scope Part   
 --select d.ApplicationId,b.ApplicationName,aac.ScopeName,aac.ID as 'ApplicationScopeID' into #AppScope   
 --from   
 ----ADM.ALMApplicationDetails a   
 -- #app d --on a.ApplicationID=d.ApplicationID  
 --join [ADM].[AppInventoryCognizant_Upload] b on d.ApplicationName=b.ApplicationName  
 --join [ADM].ApplicationScope aac on aac.ScopeName in (SELECT Item FROM dbo.Split(b.ApplicationScope, ','))  
 --where b.CustomerID=@CustomerId  
 --and aac.IsDeleted='0'  



 ---------------New Add 7-------------

 --select d.ApplicationId,b.ApplicationName,b.OtherUnitTestFramework as 'OtherUnitTestFramework',aac.UnitTestFrameworkID as 'UnitTestFrameworkID' into #tempUnitTestingData 
 --from 
 ----ADM.ALMApplicationDetails a 
 --#app d --on a.ApplicationID=d.ApplicationID
 --join [ADM].[AppInventoryUnitTestingCognizant_Upload] b on d.ApplicationName=b.ApplicationName
 --join [PP].[MAS_UnitTestingFramework] aac on aac.FrameWorkName in (SELECT Item FROM dbo.Split(b.UnitTestFrameworkID, ','))
 ----WHERE b.CustomerId=@CustomerId
 --and aac.IsDeleted='0' 

 --IF EXISTS(SELECT 1 FROM #tempUnitTestingData) 
 --BEGIN
 ---- DROP Application Scope 
	--DELETE FROM [PP].[MAP_UnitTestingFramework] WHERE ApplicationId in (SELECT ApplicationID FROM #app)

	---- Updating AppApplicationScope 
	--INSERT INTO [PP].[MAP_UnitTestingFramework](ApplicationId,UnitTestFrameworkID,OtherUnitTestFramework,IsDeleted,CreatedBy,CreatedOn)
	--SELECT aa.ApplicationId,aa.UnitTestFrameworkID,aa.OtherUnitTestFramework,0,'System',GETDATE() FROM #tempUnitTestingData aa
 --END
-- -------------added----------------

-- 	select s.ID,s.ApplicationName,s.ApplicationScope,s.IsRevenue,s.IsAnySIVendor,s.GeographiesSupported,s.FunctionalKnowledge,s.ExecutionMethod
--,s.OtherExecutionMethod,s.SourceCodeAvailability,s.RegulatoryBody,s.OtherRegulatoryBody,s.IsAppAvailable,s.AvailabilityPercent,s.IsCognizant
--,s.CustomerId,s.IsValid,s.IsDeleted,s.CreatedBy,s.CreatedDate,s.ModifiedBy
--,s.ModifiedDate,a.ApplicationID into #ALMApplicationTemp from [ADM].[AppInventoryCognizant_Upload] s join #app a on s.ApplicationName=a.ApplicationName
		
--		 declare @CustomerCount int=Null
--		 select @CustomerCount =count(AM.ApplicationID) from  #ALMApplicationTemp AM where ApplicationID 		
--		 not in (select ApplicationID from ADM.ALMApplicationDetails)
--		 If (@CustomerCount >0)
--		 Begin 
--		 INSERT INTO ADM.ALMApplicationDetails(ApplicationID,IsRevenue,IsAnySIVendor,FunctionalKnowledge,
--											ExecutionMethod,OtherExecutionMethod,SourceCodeAvailability,
--											OtherRegulatoryBody,IsAppAvailable,AvailabilityPercentage,IsDeleted,
--											CreatedBy,CreatedDate)
--			SELECT ND.ApplicationID,
--			CASE 
--				WHEN LOWER( b.IsRevenue) ='yes'  THEN 1
--				WHEN LOWER(b.IsRevenue) ='no'  THEN 0 END,
--			CASE 
--				WHEN LOWER( b.IsAnySIVendor) ='yes'  THEN 1
--				WHEN  LOWER(b.IsAnySIVendor) ='no'  THEN 0 END,
--			F.ID,EM.ID,	b.OtherExecutionMethod,SC.ID,b.OtherRegulatoryBody,
--			CASE 
--				WHEN LOWER( b.IsAppAvailable) ='yes'  THEN 1
--				WHEN  LOWER(b.IsAppAvailable) ='no'  THEN 0
--				WHEN  LOWER(b.IsAppAvailable) ='na'  THEN NULL END,
--			b.AvailabilityPercent,0, ND.CreatedBy,GETDATE()
--			FROM #ALMApplicationTemp ND 
--			--JOIN #newAppDetails NA on ND.ApplicationName=NA.ApplicationName
--			JOIN [ADM].[AppInventoryCognizant_Upload] b on ND.ApplicationName=b.ApplicationName
--			LEFT JOIN ADM.FunctionalKnowledge F on b.FunctionalKnowledge=F.FunctionalKnowledgeName AND F.isdeleted=0
--			LEFT JOIN [ADM].[ExecutionMethod] EM on b.ExecutionMethod=EM.ExecutionMethodName AND EM.isdeleted=0
--			LEFT JOIN [ADM].[SourceCodeAvailability] SC on B.SourceCodeAvailability=SC.[SourceCodeName] AND SC.IsDeleted=0
--			WHERE b.CustomerId=@CustomerId
--		 End

 
--	----------------
--	DELETE FROM  [PP].[AppInventoryRCMAttributes] WHERE ApplicationId in (SELECT ApplicationID FROM #app)
--	Insert into [PP].[AppInventoryRCMAttributes] (ApplicationID,NFRCaptured,IsUnitTestAutomated,TestingCoverage,IsRegressionTest,RegressionTestCoverage,IsDeleted,CreatedBy,CreatedOn)
--	 SELECT ND.ApplicationID,b.NFRCaptured,
--			CASE 
--				WHEN LOWER( b.IsUnitTestAutomated) ='yes'  THEN 1
--				WHEN  LOWER(b.IsUnitTestAutomated) ='no'  THEN 0 END,
--			b.TestingCoverage,
--			CASE 
--				WHEN LOWER( b.IsRegressionTest) ='yes'  THEN 1
--				WHEN  LOWER(b.IsRegressionTest) ='no'  THEN 0 end,
--			b.RegressionTestCoverage,0, 'System',GETDATE()
--			FROM #app ND 
--			JOIN  [ADM].[AppInventoryUnitTestingCognizant_Upload] b on ND.ApplicationName=b.ApplicationName
--			WHERE b.CustomerId=@CustomerId


--	---------------

--  ---------------New Add 7-------------  
  
-- IF EXISTS(SELECT 1 FROM #AppScope)  
-- BEGIN   
  
-- -- DROP Application Scope   
-- --DELETE FROM ADM.AppApplicationScope WHERE ApplicationId in (SELECT ApplicationID FROM #app)  
  
-- ---- Updating AppApplicationScope   
-- --INSERT INTO ADM.AppApplicationScope(ApplicationId,ApplicationScopeId,IsDeleted,CreatedBy,CreatedDate)  
-- --SELECT aa.ApplicationId,aa.ApplicationScopeID,0,'System',GETDATE() FROM #AppScope aa  

-- update  AAS set AAS.ApplicationScopeId=aa.ApplicationScopeID,AAS.IsDeleted='0',
-- AAS.CreatedBy='System',AAS.CreatedDate=getdate() from ADM.AppApplicationScope AAS join #AppScope aa
-- on AAS.ApplicationId=aa.ApplicationId

-- END  
-- DROP TABLE #AppScope  
  
-- -- Geographic part   
-- select d.ApplicationId,b.ApplicationName,aac.GeographiesName,aac.ID as 'GeographiesSupportedID' into #AppGeographic   
-- from   
--  #app d   
-- join [ADM].[AppInventoryCognizant_Upload] b on d.ApplicationName=b.ApplicationName  
-- join [ADM].GeographiesSupported aac on aac.GeographiesName in (SELECT Item FROM dbo.Split(b.GeographiesSupported, ','))  
-- where b.CustomerID=@CustomerId  
-- and aac.IsDeleted='0'   
  
-- IF EXISTS(SELECT 1 FROM #AppGeographic)  
-- BEGIN   
  
-- --DELETE FROM ADM.AppGeographies WHERE ApplicationId in (SELECT ApplicationID FROM #app)  
  
-- --INSERT INTO ADM.AppGeographies(ApplicationId,GeographyId,IsDeleted,CreatedBy,CreatedDate)  
-- -- SELECT ApplicationID,GeographiesSupportedID,0,'System',GETDATE() FROM #AppGeographic  

--  update  AG set AG.GeographyId=aa.GeographiesSupportedID,AG.IsDeleted='0',AG.CreatedBy='System',AG.CreatedDate=GETDATE()
-- from ADM.AppGeographies AG join #AppGeographic aa
-- on AG.ApplicationId=aa.ApplicationId
  
--END  
  
--DROP TABLE #AppGeographic  
  
----Regulatory Body Part  
-- SELECT d.ApplicationId,b.ApplicationName,aac.RegulatoryBodyName,aac.ID as 'RegulatoryBodyID' into #AppRegulatoryBody   
-- FROM   
--  #app d   
-- join [ADM].[AppInventoryCognizant_Upload] b on d.ApplicationName=b.ApplicationName  
-- join [ADM].RegulatoryBody aac on aac.RegulatoryBodyName in (SELECT Item FROM dbo.Split(b.RegulatoryBody, ','))  
-- where b.CustomerID=@CustomerId  
-- and aac.IsDeleted='0'   
  
-- IF EXISTS(SELECT 1 FROM #AppRegulatoryBody)  
-- BEGIN   
    
--  --DELETE FROM ADM.AppRegulatoryBody WHERE ApplicationId in (SELECT ApplicationID FROM #app)  
  
--  --INSERT INTO ADM.AppRegulatoryBody(ApplicationId,RegulatoryId,IsDeleted,CreatedBy,CreatedDate)  
--  --SELECT ApplicationID,RegulatoryBodyID,0,'System',GETDATE() FROM #AppRegulatoryBody  

--  update  AR set AR.RegulatoryId=RegulatoryBodyID,AR.IsDeleted='0',AR.CreatedBy='System',AR.CreatedDate=getdate()
-- from ADM.AppRegulatoryBody AR join #AppRegulatoryBody aa
-- on AG.ApplicationId=aa.ApplicationId
  
-- END  
  
-- DROP TABLE #AppRegulatoryBody  
 --DROP TABLE #tempUnitTestingData 
SET NOCOUNT OFF;

COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[AddAppInvDetailsToTemp_Cognizant]', @ErrorMessage, 0,@CustomerId
		
	END CATCH  
END
