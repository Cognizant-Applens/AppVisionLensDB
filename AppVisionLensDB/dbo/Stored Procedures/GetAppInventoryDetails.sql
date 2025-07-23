/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
--[dbo].[GetAppInventoryDetails] 'GetAppInventoryData','7097','1',1
CREATE PROCEDURE [dbo].[GetAppInventoryDetails] --'GetAppInventoryData','7097','1',1
@Mode varchar(50)=null,
@CustomerId varchar(50)=null,
@isCognizant varchar(10)=null,
@isDebt bigint =NULL
AS

BEGIN
	BEGIN TRY
	SET NOCOUNT ON;

--Download AppInventory start
	if(@Mode='CheckCustomerInc')
	   BEGIN
		  SELECT IsCognizant FROM AVL.Customer (NOLOCK) WHERE CustomerID=@CustomerId
	   END
 --Cognizant  
   ELSE if(@Mode='GetAppInventoryData' AND @isCognizant='1')
         BEGIN

			CREATE TABLE #temp(
			ApplicationID int,
			IsRevenue Varchar(100),
			--//IsAnySIVendor Varchar(100),
			FunctionalKnowledgeName Varchar(100),
			ExecutionMethodName Varchar(100),
			OtherExecutionMethod Varchar(100),
			SourceCodeName Varchar(100),
			OtherRegulatoryBody Varchar(100),
			IsAppAvailable Varchar(100),
			AvailabilityPercentage Varchar(100),
			IsDeleted int,
			CreatedBy Varchar(100),
			CreatedDate datetime,
			ModifiedBy Varchar(100),
			ModifiedDate datetime
			)


			 Insert into #temp (ApplicationID,IsRevenue,FunctionalKnowledgeName,ExecutionMethodName,OtherExecutionMethod,SourceCodeName,OtherRegulatoryBody,IsAppAvailable,AvailabilityPercentage,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)








			 select AM.ApplicationID, 
			 REPLACE(REPLACE(AM.IsRevenue, 0, 'No'),1, 'Yes') As IsRevenue,
			 --REPLACE(REPLACE(AM.IsAnySIVendor, 0, 'No'),1, 'Yes') As IsAnySIVendor,
			 Fk.FunctionalKnowledgeName,
			 EM.ExecutionMethodName,AM.OtherExecutionMethod,SCA.SourceCodeName,AM.OtherRegulatoryBody,
					--CASE WHEN AM.IsAppAvailable IS NULL OR AM.IsAppAvailable=''
					--THEN 
					--'' 
					--ELSE 
					REPLACE(REPLACE(REPLACE(AM.IsAppAvailable, 0, 'No'),1, 'Yes'),2,'NA')
					 IsAppAvailable,--END as
			 (CASE  
			  WHEN AM.AvailabilityPercentage=0.00 THEN
			  REPLACE(ISNULL(AM.AvailabilityPercentage, ''),0.00,'') 
			  ELSE REPLACE(AM.AvailabilityPercentage, '.00', '')
			 END) AS AvailabilityPercentage,
			 AM.IsDeleted,AM.CreatedBy,AM.CreatedDate,AM.ModifiedBy,AM.ModifiedDate
			 from 
			  avl.BusinessClusterMapping b (NOLOCK)
			 JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) on AD.SubBusinessClusterMapID=b.BusinessClusterMapID 
								and b.IsHavingSubBusinesss='0' 
			 JOIN ADM.ALMApplicationDetails AM (NOLOCK) ON AD.ApplicationID=AM.ApplicationID 
			 left join ADM.FunctionalKnowledge FK (NOLOCK) on am.FunctionalKnowledge=fk.ID
			 --left join ADM.ExecutionMethod EM on am.ExecutionMethod=EM.ID
			 left join (SELECT PPA.AttributeValueID AS ID, PPA.AttributeValueName AS ExecutionMethodName from Mas.PPAttributeValues (NOLOCK) PPA
			 INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0
			 WHERE AttributeName = 'ExecutionMethod') EM on am.ExecutionMethod=EM.ID
			 left join ADM.SourceCodeAvailability SCA (NOLOCK) on SCA.ID=AM.SourceCodeAvailability
			 WHERE B.CustomerID=@CustomerId


			
			select RB.RegulatoryBodyName,t.ApplicationId,t.IsDeleted,t.CreatedBy 
			into #TBody 
			from 
			 avl.BusinessClusterMapping b (NOLOCK)
			 JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) on AD.SubBusinessClusterMapID=b.BusinessClusterMapID 
								and b.IsHavingSubBusinesss='0' 
			join ADM.AppRegulatoryBody t (NOLOCK) on t.ApplicationId=AD.ApplicationID
			Left join 
			ADM.RegulatoryBody RB ON t.RegulatoryId = RB.ID
			WHERE B.CustomerID=@CustomerId

			SELECT [ApplicationId], RegulatoryBodyName = 
				STUFF((SELECT ', ' + RegulatoryBodyName
					   FROM #TBody b 
					   WHERE b.[ApplicationId] = a.[ApplicationId] 
					  FOR XML PATH('')), 1, 2, '') 
			into #TBodyFan
			FROM #TBody a
			GROUP BY [ApplicationId]


			select AG.GeographiesName,t.ApplicationId,t.IsDeleted,t.CreatedBy 
			into #TGeo 
			from 
			 avl.BusinessClusterMapping b 
			 JOIN AVL.APP_MAS_ApplicationDetails AD on AD.SubBusinessClusterMapID=b.BusinessClusterMapID 
								and b.IsHavingSubBusinesss='0' 
			JOIN ADM.AppGeographies t on t.ApplicationId=ad.ApplicationID
			Left join 
			ADM.GeographiesSupported AG ON t.GeographyId = AG.ID
			WHERE B.CustomerID=@CustomerId

			SELECT [ApplicationId], GeographiesName = 
				STUFF((SELECT ', ' + GeographiesName
					   FROM #TGeo b 
					   WHERE b.[ApplicationId] = a.[ApplicationId] 
					  FOR XML PATH('')), 1, 2, '') into #TGeoFan
			FROM #TGeo a (NOLOCK)
			GROUP BY [ApplicationId]


			select AAS.ScopeName,t.ApplicationId,t.IsDeleted,t.CreatedBy 
			into #TScope 
			from 
			 avl.BusinessClusterMapping b (NOLOCK)
			 JOIN AVL.APP_MAS_ApplicationDetails AD on AD.SubBusinessClusterMapID=b.BusinessClusterMapID 
								and b.IsHavingSubBusinesss='0' 
			JOIN ADM.AppApplicationScope t on t.ApplicationId=ad.ApplicationID
			Left join 
			ADM.ApplicationScope AAS ON t.ApplicationScopeId = AAS.ID
			WHERE B.CustomerID=@CustomerId

			SELECT [ApplicationId], ScopeName = 
				STUFF((SELECT ', ' + ScopeName
					   FROM #TScope b 
					   WHERE b.[ApplicationId] = a.[ApplicationId] 
					  FOR XML PATH('')), 1, 2, '') into #TScopeFan
			FROM #TScope a
			GROUP BY [ApplicationId]
			
			  select b.ApplicationId, utf.FrameWorkName,b.OtherUnitTestFramework,b.IsDeleted,b.CreatedBy 
			into #tempUnitTesting 
			from avl.BusinessClusterMapping bc (NOLOCK)
			 JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) on AD.SubBusinessClusterMapID=bc.BusinessClusterMapID and bc.IsHavingSubBusinesss='0'
			 join[PP].[MAP_UnitTestingFramework]  b (NOLOCK) on b.ApplicationID=ad.ApplicationID
			left JOIN [PP].[MAS_UnitTestingFramework] utf on utf.UnitTestFrameworkID=b.UnitTestFrameworkID
			where bc.CustomerID=@CustomerId and b.isdeleted=0
			
			 SELECT [ApplicationId], FrameWorkName = 
				STUFF((SELECT ', ' + FrameWorkName
					   FROM #tempUnitTesting b 
					   WHERE b.[ApplicationId] = a.[ApplicationId] 
					  FOR XML PATH('')), 1, 2, '')	 into #tempUnitTestingData		 
			FROM  #tempUnitTesting a (NOLOCK)
			GROUP BY [ApplicationId]

			  select DISTINCT  a.ApplicationId,a.OtherUnitTestFramework
			 into #tempUnitTestingFramework 
			 from 
			  [PP].[MAP_UnitTestingFramework] a (NOLOCK) join [PP].[MAS_UnitTestingFramework] b (NOLOCK)
			  on a.UnitTestFrameworkID=b.UnitTestFrameworkID
			  where a.OtherUnitTestFramework is not null and a.OtherUnitTestFramework<>'' and b.UnitTestFrameworkID='4'


			    select 
				ARC.ApplicationID
			    ,ARC.NFRCaptured
				,ARC.IsUnitTestAutomated				
				,TUT.FrameWorkName
				,tf.OtherUnitTestFramework
				,ARC.TestingCoverage
				,ARC.IsRegressionTest
				,ARC.RegressionTestCoverage into #finalData
				from 
				pp.ApplicationQualityAttributes ARC (NOLOCK)
			   left JOIN #tempUnitTestingData TUT (NOLOCK) ON ARC.ApplicationID=TUT.ApplicationID
			   left JOIN #tempUnitTestingFramework tf (NOLOCK) on ARC.ApplicationID=tf.ApplicationID
				--select * from #finalData

			 SELECT DISTINCT  
			 Vw.ApplicationName
			 ,ISNULL(Vw.ApplicationCode,'') AS ApplicationCode
			 ,Vw.ApplicationShortName
			 ,Vw.BusinessClusterBaseName
			 ,Vw.ApplicationTypename --CodeOwnerShip
			 ,Vw.BusinessCriticalityName
			 ,Vw.PrimaryTechnologyName
			 ,ISNULL(Vw.ProductMarketName,'') AS ProductMarketName
			 ,Vw.ApplicationDescription
			 , format(cast(Vw.ApplicationCommisionDate as date), 'MM/dd/yyyy') AS ApplicationCommisionDate
			 ,Vw.RegulatoryCompliantName
			 ,ISNULL(Vw.DebtcontrolScopeName,'') AS DebtcontrolScopeName
			 ,ISNULL(Vw.UserBase,'') AS UserBase
			 ,ISNULL(Vw.SupportWindowName,'') AS SupportWindowName	
			 ,ISNULL(Vw.SupportCategoryName,'') AS SupportCategoryName
			 ,ISNULL(Vw.OperatingSystem,'') AS OperatingSystem
			 ,ISNULL(Vw.ServerConfiguration,'') AS ServerConfiguration
			 ,ISNULL(Vw.ServerOwner,'') AS ServerOwner
			 ,ISNULL(Vw.LicenseDetails,'') AS LicenseDetails
			 ,ISNULL(Vw.DatabaseVersion,'') AS DatabaseVersion
			 ,ISNULL(Vw.HostedEnvironmentName,'') AS HostedEnvironmentName
			 ,ISNULL(Vw.CloudServiceProviderName,'') AS CloudServiceProvider
			 ,ISNULL(Vw.CloudModelName, '') AS CloudModelName
			 ,AD.OtherPrimaryTechnology
			 ,IA.OtherCloudServiceProvider
			 ,EAD.OtherSupportWindow			
			 ,SF.ScopeName
			 ,AMD.IsRevenue
			 --,AMD.IsAnySIVendor
			 ,GF.GeographiesName
			 ,AMD.FunctionalKnowledgeName
			 ,AMD.ExecutionMethodName
			 ,AMD.OtherExecutionMethod
			 ,AMD.SourceCodeName
			 ,BF.RegulatoryBodyName
			 ,AMD.OtherRegulatoryBody
			 ,ISNULL(AMD.IsAppAvailable, '') AS IsAppAvailable
			 ,REPLACE(ISNULL(AMD.AvailabilityPercentage, ''),0.00,'') AS AvailabilityPercentage
			 ,ISNULL(ARC.NFRCaptured,'') AS 'NFRCaptured'
			  ,REPLACE(REPLACE(ARC.IsUnitTestAutomated, 0, 'No'),1, 'Yes') AS 'IsUnitTestAutomated'
			 ,ISNULL(ARC.FrameWorkName,'')  AS 'UnitTestFrameworkID'
			 ,ISNULL(ARC.OtherUnitTestFramework,'') AS 'OtherUnitTestFramework'
			 ,ARC.TestingCoverage
			 ,REPLACE(REPLACE(ARC.IsRegressionTest, 0, 'No'),1, 'Yes')  AS IsRegressionTest
			 ,ARC.RegressionTestCoverage
			 ,Vw.Active		
			 FROM [dbo].[vw_applicationDetails] Vw (NOLOCK)
			 INNER JOIN AVL.Customer C (NOLOCK)
			 ON c.CustomerID = VW.CustomerID and Vw.CustomerID=@CustomerId
			 LEFT JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) ON AD.ApplicationID=Vw.ApplicationID
			 AND AD.PrimaryTechnologyID=Vw.PrimaryTechnologyID
			 LEFT JOIN AVL.APP_MAS_InfrastructureApplication IA (NOLOCK) ON IA.ApplicationID=Vw.ApplicationID
			 AND IA.CloudServiceProvider=Vw.CloudServiceProviderID
			 LEFT JOIN AVL.APP_MAS_Extended_ApplicationDetail  EAD (NOLOCK) ON EAD.ApplicationID=Vw.ApplicationID
			 AND EAD.SupportWindowID=Vw.SupportWindowID
			 LEFT JOIN #temp AMD (NOLOCK) ON AMD.ApplicationID=Vw.ApplicationID
			 LEFT JOIN #TScopeFan SF (NOLOCK) ON SF.ApplicationID=Vw.ApplicationID
			 LEFT JOIN #TGeoFan GF (NOLOCK) ON GF.ApplicationID=Vw.ApplicationID
			 LEFT JOIN #TBodyFan BF (NOLOCK) ON BF.ApplicationID=Vw.ApplicationID
			 Left JOIN #finalData ARC (NOLOCK) ON ARC.ApplicationID=Vw.ApplicationID



			SELECT DISTINCT BCM.BusinessClusterID,BCM.BusinessClusterBaseName,BC.BusinessClusterName
			FROM AVL.Customer C (NOLOCK)
			INNER JOIN AVL.BusinessCluster BC (NOLOCK)
			ON C.CustomerID=BC.CustomerID
			INNER JOIN AVL.BusinessClusterMapping BCM (NOLOCK)
			ON BC.BusinessClusterID=BCM.BusinessClusterID
			WHERE BCM.IsHavingSubBusinesss=0
			AND c.CustomerID=@CustomerId AND BCM.IsDeleted=0

			drop table #temp
			drop table  #TScope 
			drop table #TScopeFan 
			drop table #TGeo  
			drop table #TGeoFan  
			drop table #TBody  
			drop table #TBodyFan
			drop table #tempUnitTesting
			drop table #tempUnitTestingData
			drop table #tempUnitTestingFramework
			drop table #finalData
		 END

--Client

    ELSE if(@Mode='GetAppInventoryData' AND @isCognizant='0' )
	BEGIN 

			CREATE TABLE #tempClient(
			ApplicationID int,
			IsRevenue Varchar(100),
			--//IsAnySIVendor Varchar(100),
			FunctionalKnowledgeName Varchar(100),
			ExecutionMethodName Varchar(100),
			OtherExecutionMethod Varchar(100),
			SourceCodeName Varchar(100),
			OtherRegulatoryBody Varchar(100),
			IsAppAvailable Varchar(100),
			AvailabilityPercentage Varchar(100),
			IsDeleted int,
			CreatedBy Varchar(100),
			CreatedDate datetime,
			ModifiedBy Varchar(100),
			ModifiedDate datetime
			)


			 Insert into #tempClient (ApplicationID,IsRevenue,FunctionalKnowledgeName,ExecutionMethodName,OtherExecutionMethod,SourceCodeName,OtherRegulatoryBody,IsAppAvailable,AvailabilityPercentage,IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate)








			 select AM.ApplicationID, 
			 REPLACE(REPLACE(AM.IsRevenue, 0, 'No'),1, 'Yes') As IsRevenue,
			 --REPLACE(REPLACE(AM.IsAnySIVendor, 0, 'No'),1, 'Yes') As IsAnySIVendor,
			 Fk.FunctionalKnowledgeName,
			EM.ExecutionMethodName,AM.OtherExecutionMethod,SCA.SourceCodeName,AM.OtherRegulatoryBody,
					--CASE WHEN AM.IsAppAvailable IS NULL OR AM.IsAppAvailable=''
					--THEN 
					--'' 
					--ELSE 
					REPLACE(REPLACE(REPLACE(AM.IsAppAvailable, 0, 'No'),1, 'Yes'),2,'NA')
					 IsAppAvailable,--END as
			 (CASE  
			  WHEN AM.AvailabilityPercentage=0.00 THEN
			  REPLACE(ISNULL(AM.AvailabilityPercentage, ''),0.00,'') 
			  ELSE  REPLACE(AM.AvailabilityPercentage, '.00', '') 
			 END)  AS AvailabilityPercentage,
			 AM.IsDeleted,AM.CreatedBy,AM.CreatedDate,AM.ModifiedBy,AM.ModifiedDate
			 from 
			  avl.BusinessClusterMapping b (NOLOCK) 
			 JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) on AD.SubBusinessClusterMapID=b.BusinessClusterMapID 
								and b.IsHavingSubBusinesss='0' 
			 JOIN ADM.ALMApplicationDetails AM (NOLOCK) ON AD.ApplicationID=AM.ApplicationID 
			 left join ADM.FunctionalKnowledge FK (NOLOCK) on am.FunctionalKnowledge=fk.ID
			 --left join ADM.ExecutionMethod EM on am.ExecutionMethod=EM.ID
			 left join (SELECT PPA.AttributeValueID AS ID, PPA.AttributeValueName AS ExecutionMethodName from Mas.PPAttributeValues (NOLOCK) PPA
			 INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0
			 WHERE AttributeName = 'ExecutionMethod') EM on am.ExecutionMethod=EM.ID
			 left join ADM.SourceCodeAvailability SCA (NOLOCK) on SCA.ID=AM.SourceCodeAvailability
			 WHERE B.CustomerID=@CustomerId


			
			select RB.RegulatoryBodyName,t.ApplicationId,t.IsDeleted,t.CreatedBy 
			into #TBodyClient 
			from 
			 avl.BusinessClusterMapping b (NOLOCK) 
			 JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) on AD.SubBusinessClusterMapID=b.BusinessClusterMapID 
								and b.IsHavingSubBusinesss='0' 
			join ADM.AppRegulatoryBody t (NOLOCK) on t.ApplicationId=AD.ApplicationID
			Left join 
			ADM.RegulatoryBody RB (NOLOCK) ON t.RegulatoryId = RB.ID
			WHERE B.CustomerID=@CustomerId

			SELECT [ApplicationId], RegulatoryBodyName = 
				STUFF((SELECT ', ' + RegulatoryBodyName
					   FROM #TBodyClient b 
					   WHERE b.[ApplicationId] = a.[ApplicationId] 
					  FOR XML PATH('')), 1, 2, '') 
			into #TBodyFanClient
			FROM #TBodyClient a
			GROUP BY [ApplicationId]


			select AG.GeographiesName,t.ApplicationId,t.IsDeleted,t.CreatedBy 
			into #TGeoClient 
			from 
			 avl.BusinessClusterMapping b (NOLOCK)
			 JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) on AD.SubBusinessClusterMapID=b.BusinessClusterMapID 
								and b.IsHavingSubBusinesss='0' 
			JOIN ADM.AppGeographies t (NOLOCK) on t.ApplicationId=ad.ApplicationID
			Left join 
			ADM.GeographiesSupported AG ON t.GeographyId = AG.ID
			WHERE B.CustomerID=@CustomerId

			SELECT [ApplicationId], GeographiesName = 
				STUFF((SELECT ', ' + GeographiesName
					   FROM #TGeoClient b (NOLOCK)
					   WHERE b.[ApplicationId] = a.[ApplicationId] 
					  FOR XML PATH('')), 1, 2, '') into #TGeoFanClient
			FROM #TGeoClient a (NOLOCK)
			GROUP BY [ApplicationId]


			select AAS.ScopeName,t.ApplicationId,t.IsDeleted,t.CreatedBy 
			into #TScopeClient 
			from 
			 avl.BusinessClusterMapping b (NOLOCK)  
			 JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) on AD.SubBusinessClusterMapID=b.BusinessClusterMapID 
								and b.IsHavingSubBusinesss='0' 
			JOIN ADM.AppApplicationScope t (NOLOCK) on t.ApplicationId=ad.ApplicationID
			Left join 
			ADM.ApplicationScope AAS (NOLOCK) ON t.ApplicationScopeId = AAS.ID
			WHERE B.CustomerID=@CustomerId

			SELECT [ApplicationId], ScopeName = 
				STUFF((SELECT ', ' + ScopeName
					   FROM #TScopeClient b 
					   WHERE b.[ApplicationId] = a.[ApplicationId] 
					  FOR XML PATH('')), 1, 2, '') into #TScopeFanClient
			FROM #TScopeClient a
			GROUP BY [ApplicationId]
			
			  select b.ApplicationId, utf.FrameWorkName,b.OtherUnitTestFramework,b.IsDeleted,b.CreatedBy 
			into #tempUnitTestingClient 
			from avl.BusinessClusterMapping bc (NOLOCK) 
			 JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) on AD.SubBusinessClusterMapID=bc.BusinessClusterMapID and bc.IsHavingSubBusinesss='0'
			 join[PP].[MAP_UnitTestingFramework]  b (NOLOCK) on b.ApplicationID=ad.ApplicationID
			left JOIN [PP].[MAS_UnitTestingFramework] utf (NOLOCK) on utf.UnitTestFrameworkID=b.UnitTestFrameworkID
			where bc.CustomerID=@CustomerId and b.isdeleted=0
			
			 SELECT [ApplicationId], FrameWorkName = 
				STUFF((SELECT ', ' + FrameWorkName
					   FROM #tempUnitTestingClient b 
					   WHERE b.[ApplicationId] = a.[ApplicationId] 
					  FOR XML PATH('')), 1, 2, '')	 into #tempUnitTestingDataClient		 
			FROM  #tempUnitTestingClient a
			GROUP BY [ApplicationId]

			  select DISTINCT  a.ApplicationId,a.OtherUnitTestFramework
			 into #tempUnitTestingFrameworkClient 
			 from 
			  [PP].[MAP_UnitTestingFramework] a join [PP].[MAS_UnitTestingFramework] b 
			  on a.UnitTestFrameworkID=b.UnitTestFrameworkID
			  where a.OtherUnitTestFramework is not null and a.OtherUnitTestFramework<>'' and b.UnitTestFrameworkID='4'


			    select 
				ARC.ApplicationID
			    ,ARC.NFRCaptured
				,ARC.IsUnitTestAutomated				
				,TUT.FrameWorkName
				,tf.OtherUnitTestFramework
				,ARC.TestingCoverage
				,ARC.IsRegressionTest
				,ARC.RegressionTestCoverage into #finalDataClient
				from 
				pp.ApplicationQualityAttributes ARC (NOLOCK) 
			   left JOIN #tempUnitTestingDataClient TUT (NOLOCK) ON ARC.ApplicationID=TUT.ApplicationID
			   left JOIN #tempUnitTestingFrameworkClient tf (NOLOCK) on ARC.ApplicationID=tf.ApplicationID
				--select * from #finalData

			 SELECT DISTINCT  
			 Vw.ApplicationName
			 ,ISNULL(Vw.ApplicationCode,'') AS ApplicationCode
			 ,Vw.ApplicationShortName
			 ,Vw.BusinessClusterBaseName
			 ,Vw.ApplicationTypename --CodeOwnerShip
			 ,Vw.BusinessCriticalityName
			 ,Vw.PrimaryTechnologyName
			 ,ISNULL(Vw.ProductMarketName,'') AS ProductMarketName
			 ,Vw.ApplicationDescription
			 , format(cast(Vw.ApplicationCommisionDate as date), 'MM/dd/yyyy') AS ApplicationCommisionDate
			 ,Vw.RegulatoryCompliantName
			 ,ISNULL(Vw.DebtcontrolScopeName,'') AS DebtcontrolScopeName
			 ,ISNULL(Vw.UserBase,'') AS UserBase
			 ,ISNULL(Vw.SupportWindowName,'') AS SupportWindowName	
			 ,ISNULL(Vw.SupportCategoryName,'') AS SupportCategoryName
			 ,ISNULL(Vw.OperatingSystem,'') AS OperatingSystem
			 ,ISNULL(Vw.ServerConfiguration,'') AS ServerConfiguration
			 ,ISNULL(Vw.ServerOwner,'') AS ServerOwner
			 ,ISNULL(Vw.LicenseDetails,'') AS LicenseDetails
			 ,ISNULL(Vw.DatabaseVersion,'') AS DatabaseVersion
			 ,ISNULL(Vw.HostedEnvironmentName,'') AS HostedEnvironmentName
			 ,ISNULL(Vw.CloudServiceProviderName,'') AS CloudServiceProvider
			 ,ISNULL(Vw.CloudModelName, '') AS CloudModelName
			 ,AD.OtherPrimaryTechnology
			 ,IA.OtherCloudServiceProvider
			 ,EAD.OtherSupportWindow			
			 ,Replace(SF.ScopeName,', Development/Testing','') as ScopeName   
			 ,AMD.IsRevenue
			 --,AMD.IsAnySIVendor
			 ,GF.GeographiesName
			 ,AMD.FunctionalKnowledgeName
			 ,'' AS ExecutionMethodName  
			 ,'' AS OtherExecutionMethod  
			 ,AMD.SourceCodeName  
			 ,BF.RegulatoryBodyName  
			 ,AMD.OtherRegulatoryBody  
			 ,ISNULL(AMD.IsAppAvailable, '') AS IsAppAvailable  
			 ,AMD.AvailabilityPercentage  
			 ,'' AS NFRCaptured 
			 ,'' AS IsUnitTestAutomated  
			 ,'' AS UnitTestFrameworkID
			 ,'' AS OtherUnitTestFramework
			 ,'' AS TestingCoverage  
			 ,'' AS IsRegressionTest  
			 ,'' AS RegressionTestCoverage  
			 ,ISNULL(Vw.Incallwdgreen,'') AS Incallwdgreen
			 ,ISNULL(Vw.Infraallwdgreen,'') AS Infraallwdgreen
			 ,ISNULL(Vw.Incallwdamber,'') AS Incallwdamber
			 ,ISNULL(Vw.Infraallwdamber,'') AS Infraallwdamber
			 ,ISNULL(Vw.Infoallwdamber,'') AS Infoallwdamber
			 ,ISNULL(Vw.Infoallwdgreen,'') AS Infoallwdgreen
			 ,Vw.Active		
			 FROM [dbo].[vw_applicationDetails] Vw
			 INNER JOIN AVL.Customer C (NOLOCK) 
			 ON c.CustomerID = VW.CustomerID and Vw.CustomerID=@CustomerId
			 LEFT JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK) ON AD.ApplicationID=Vw.ApplicationID
			 AND AD.PrimaryTechnologyID=Vw.PrimaryTechnologyID
			 LEFT JOIN AVL.APP_MAS_InfrastructureApplication IA (NOLOCK) ON IA.ApplicationID=Vw.ApplicationID
			 AND IA.CloudServiceProvider=Vw.CloudServiceProviderID
			 LEFT JOIN AVL.APP_MAS_Extended_ApplicationDetail  EAD (NOLOCK) ON EAD.ApplicationID=Vw.ApplicationID
			 AND EAD.SupportWindowID=Vw.SupportWindowID
			 LEFT JOIN #tempClient AMD (NOLOCK) ON AMD.ApplicationID=Vw.ApplicationID
			 LEFT JOIN #TScopeFanClient SF (NOLOCK) ON SF.ApplicationID=Vw.ApplicationID
			 LEFT JOIN #TGeoFanClient GF (NOLOCK) ON GF.ApplicationID=Vw.ApplicationID
			 LEFT JOIN #TBodyFanClient BF (NOLOCK) ON BF.ApplicationID=Vw.ApplicationID
			 Left JOIN #finalDataClient ARC (NOLOCK) ON ARC.ApplicationID=Vw.ApplicationID



			SELECT DISTINCT BCM.BusinessClusterID,BCM.BusinessClusterBaseName,BC.BusinessClusterName
			FROM AVL.Customer C
			INNER JOIN AVL.BusinessCluster BC 
			ON C.CustomerID=BC.CustomerID
			INNER JOIN AVL.BusinessClusterMapping BCM
			ON BC.BusinessClusterID=BCM.BusinessClusterID
			WHERE BCM.IsHavingSubBusinesss=0
			AND c.CustomerID=@CustomerId AND BCM.IsDeleted=0

			drop table #tempClient
			drop table #TScopeClient 
			drop table #TScopeFanClient 
			drop table #TGeoClient  
			drop table #TGeoFanClient  
			drop table #TBodyClient  
			drop table #TBodyFanClient
			drop table #tempUnitTestingClient
			drop table #tempUnitTestingDataClient
			drop table #tempUnitTestingFrameworkClient
			drop table #finalDataClient

		--SELECT DISTINCT 
		--	 Vw.ApplicationName
		--	 ,ISNULL(Vw.ApplicationCode,'') AS ApplicationCode
		--	 ,Vw.ApplicationShortName
		--	 ,Vw.BusinessClusterBaseName
		--	 ,Vw.ApplicationTypename --CodeOwnerShip
		--	 ,Vw.BusinessCriticalityName
		--	 ,Vw.PrimaryTechnologyName
		--	 ,ISNULL(Vw.ProductMarketName,'') AS ProductMarketName
		--	 ,Vw.ApplicationDescription
		--	 ,format(cast(Vw.ApplicationCommisionDate as date), 'MM/dd/yyyy') AS ApplicationCommisionDate
		--	 ,Vw.RegulatoryCompliantName
		--	 ,ISNULL(Vw.DebtcontrolScopeName,'') AS DebtcontrolScopeName
		--	 ,ISNULL(Vw.UserBase,'') AS UserBase
		--	 ,ISNULL(Vw.Incallwdgreen,'') AS Incallwdgreen
		--	 ,ISNULL(Vw.Infraallwdgreen,'') AS Infraallwdgreen
		--	 ,ISNULL(Vw.Incallwdamber,'') AS Incallwdamber
		--	 ,ISNULL(Vw.Infraallwdamber,'') AS Infraallwdamber
		--	 ,ISNULL(Vw.Infoallwdamber,'') AS Infoallwdamber
		--	 ,ISNULL(Vw.Infoallwdgreen,'') AS Infoallwdgreen
		--	 ,ISNULL(Vw.OperatingSystem,'') AS OperatingSystem
		--	 ,ISNULL(Vw.ServerConfiguration,'') AS ServerConfiguration
		--	 ,ISNULL(Vw.ServerOwner,'') AS ServerOwner
		--	 ,ISNULL(Vw.LicenseDetails,'') AS LicenseDetails
		--	 ,ISNULL(Vw.DatabaseVersion,'') AS DatabaseVersion
		--	 ,ISNULL(Vw.HostedEnvironmentName,'') AS HostedEnvironmentName	 
		--	 ,ISNULL(Vw.CloudServiceProviderName,'') AS CloudServiceProvider
		--	 ,ISNULL(Vw.CloudModelName, '') AS CloudModelName
		--	 ,AD.OtherPrimaryTechnology
		--	 ,IA.OtherCloudServiceProvider
		--	 ,Vw.Active		
		--	 FROM [dbo].[vw_applicationDetails] Vw
		--	 INNER JOIN AVL.Customer C
		--	 ON Vw.CustomerID=@CustomerId
		--	 LEFT JOIN AVL.APP_MAS_ApplicationDetails AD ON AD.ApplicationID=Vw.ApplicationID
		--	 AND AD.PrimaryTechnologyID=Vw.PrimaryTechnologyID
		--	 LEFT JOIN AVL.APP_MAS_InfrastructureApplication IA ON IA.ApplicationID=Vw.ApplicationID
		--	 AND IA.CloudServiceProvider=Vw.CloudServiceProviderID


		--	SELECT DISTINCT BCM.BusinessClusterID,BCM.BusinessClusterBaseName,BC.BusinessClusterName
		--	FROM AVL.Customer C
		--	INNER JOIN AVL.BusinessCluster BC 
		--	ON C.CustomerID=BC.CustomerID
		--	INNER JOIN AVL.BusinessClusterMapping BCM
		--	ON BC.BusinessClusterID=BCM.BusinessClusterID
		--	WHERE BCM.IsHavingSubBusinesss=0
		--	AND c.CustomerID=@CustomerId AND BCM.IsDeleted=0

			 
	END
	
	--ELSE if(@Mode='GetAppInventoryData' AND @isCognizant='0' AND @isDebt=1)
	--BEGIN 
	--	SELECT DISTINCT 
	--		 Vw.ApplicationName
	--		 ,ISNULL(Vw.ApplicationCode,'') AS ApplicationCode
	--		 ,Vw.ApplicationShortName
	--		 ,Vw.BusinessClusterBaseName
	--		 ,Vw.ApplicationTypename --CodeOwnerShip
	--		 ,Vw.BusinessCriticalityName
	--		 ,Vw.PrimaryTechnologyName
	--		 ,ISNULL(Vw.ProductMarketName,'') AS ProductMarketName
	--		 ,Vw.ApplicationDescription
	--		 ,format(cast(Vw.ApplicationCommisionDate as date), 'MM/dd/yyyy') AS ApplicationCommisionDate
	--		 ,Vw.RegulatoryCompliantName
	--		 ,'Yes' AS DebtcontrolScopeName
	--		 ,ISNULL(Vw.UserBase,'') AS UserBase
	--		 ,ISNULL(Vw.Incallwdgreen,'') AS Incallwdgreen
	--		 ,ISNULL(Vw.Infraallwdgreen,'') AS Infraallwdgreen
	--		 ,ISNULL(Vw.Incallwdamber,'') AS Incallwdamber
	--		 ,ISNULL(Vw.Infraallwdamber,'') AS Infraallwdamber
	--		 ,ISNULL(Vw.Infoallwdamber,'') AS Infoallwdamber
	--		 ,ISNULL(Vw.Infoallwdgreen,'') AS Infoallwdgreen
	--		 ,ISNULL(Vw.OperatingSystem,'') AS OperatingSystem
	--		 ,ISNULL(Vw.ServerConfiguration,'') AS ServerConfiguration
	--		 ,ISNULL(Vw.ServerOwner,'') AS ServerOwner
	--		 ,ISNULL(Vw.LicenseDetails,'') AS LicenseDetails
	--		 ,ISNULL(Vw.DatabaseVersion,'') AS DatabaseVersion
	--		 ,ISNULL(Vw.HostedEnvironmentName,'') AS HostedEnvironmentName	
	--		 ,ISNULL(Vw.CloudServiceProviderName,'') AS CloudServiceProvider
	--		 ,ISNULL(Vw.CloudModelName, '') AS CloudModelName
	--		 ,AD.OtherPrimaryTechnology
	--		 ,IA.OtherCloudServiceProvider
	--		 ,Vw.Active		
	--		 FROM [dbo].[vw_applicationDetails] Vw
	--		 INNER JOIN AVL.Customer C
	--		 ON Vw.CustomerID=@CustomerId
	--		 LEFT JOIN AVL.APP_MAS_ApplicationDetails AD ON AD.ApplicationID=Vw.ApplicationID
	--		 AND AD.PrimaryTechnologyID=Vw.PrimaryTechnologyID
	--		 LEFT JOIN AVL.APP_MAS_InfrastructureApplication IA ON IA.ApplicationID=Vw.ApplicationID
	--		 AND IA.CloudServiceProvider=Vw.CloudServiceProviderID


	--		SELECT DISTINCT BCM.BusinessClusterID,BCM.BusinessClusterBaseName,BC.BusinessClusterName
	--		FROM AVL.Customer C
	--		INNER JOIN AVL.BusinessCluster BC 
	--		ON C.CustomerID=BC.CustomerID
	--		INNER JOIN AVL.BusinessClusterMapping BCM
	--		ON BC.BusinessClusterID=BCM.BusinessClusterID
	--		WHERE BCM.IsHavingSubBusinesss=0
	--		AND c.CustomerID=@CustomerId AND BCM.IsDeleted=0
			 
	--END

--Both
	 IF(@Mode='GetAppInventoryData' AND @isCognizant='2')
	      BEGIN
			 SELECT DISTINCT 
			  Vw.ApplicationName
			 ,ISNULL(Vw.ApplicationCode,'') AS ApplicationCode
			 ,Vw.ApplicationShortName
			 ,Vw.BusinessClusterBaseName
			 ,Vw.ApplicationTypename --CodeOwnerShip
			 ,Vw.BusinessCriticalityName
			 ,Vw.PrimaryTechnologyName
			 ,ISNULL(Vw.ProductMarketName,'') AS ProductMarketName
			 ,Vw.ApplicationDescription
			 ,format(cast(Vw.ApplicationCommisionDate as date), 'MM/dd/yyyy') AS ApplicationCommisionDate
			 ,Vw.RegulatoryCompliantName
			 ,ISNULL(Vw.DebtcontrolScopeName,'') AS DebtcontrolScopeName
			 ,ISNULL(Vw.UserBase,'') AS UserBase
			 ,ISNULL(Vw.SupportWindowName,'') AS SupportWindowName
			 ,ISNULL(Vw.Incallwdgreen,'') AS Incallwdgreen
			 ,ISNULL(Vw.Infraallwdgreen,'') AS Infraallwdgreen
			 ,ISNULL(Vw.Incallwdamber,'') AS Incallwdamber
			 ,ISNULL(Vw.Infraallwdamber,'') AS Infraallwdamber
			 ,ISNULL(Vw.Infoallwdamber,'') AS Infoallwdamber
			 ,ISNULL(Vw.Infoallwdgreen,'') AS Infoallwdgreen
			 ,ISNULL(Vw.SupportCategoryName,'') AS SupportCategoryName
			 ,ISNULL(Vw.OperatingSystem,'') AS OperatingSystem
			 ,ISNULL(Vw.ServerConfiguration,'') AS ServerConfiguration
			 ,ISNULL(Vw.ServerOwner,'') AS ServerOwner
			 ,ISNULL(Vw.LicenseDetails,'') AS LicenseDetails
			 ,ISNULL(Vw.DatabaseVersion,'') AS DatabaseVersion
			 ,ISNULL(Vw.HostedEnvironmentName,'') AS HostedEnvironmentName	 
			 ,ISNULL(Vw.CloudServiceProviderName,'') AS CloudServiceProvider
			 ,ISNULL(Vw.CloudModelName, '') AS CloudModelName
			 ,AD.OtherPrimaryTechnology
			 ,IA.OtherCloudServiceProvider
			 ,EAD.OtherSupportWindow
			 ,Vw.Active		
			 FROM [dbo].[vw_applicationDetails] Vw 
			 INNER JOIN AVL.Customer C (NOLOCK)
			 ON Vw.CustomerID=@CustomerId
			 LEFT JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK)ON AD.ApplicationID=Vw.ApplicationID
			 AND AD.PrimaryTechnologyID=Vw.PrimaryTechnologyID
			 LEFT JOIN AVL.APP_MAS_InfrastructureApplication IA (NOLOCK)ON IA.ApplicationID=Vw.ApplicationID
			 AND IA.CloudServiceProvider=Vw.CloudServiceProviderID
			 LEFT JOIN AVL.APP_MAS_Extended_ApplicationDetail  EAD (NOLOCK)ON EAD.ApplicationID=Vw.ApplicationID
			 AND EAD.SupportWindowID=Vw.SupportWindowID


			SELECT DISTINCT BCM.BusinessClusterID,BCM.BusinessClusterBaseName,BC.BusinessClusterName
			FROM AVL.Customer C (NOLOCK)
			INNER JOIN AVL.BusinessCluster BC (NOLOCK)
			ON C.CustomerID=BC.CustomerID
			INNER JOIN AVL.BusinessClusterMapping BCM (NOLOCK)
			ON BC.BusinessClusterID=BCM.BusinessClusterID
			WHERE BCM.IsHavingSubBusinesss=0
			AND c.CustomerID=@CustomerId AND BCM.IsDeleted=0
			 
		 END

--Download AppInventory End

--Upload for AppInventory Start
ELSE if(@Mode='CheckApplicationFields' AND @isCognizant='0')

	BEGIN
	SELECT  ID,
			ColumnID,
			ColumnName,
			DataType,
			MandatoryID,
			ParentColumnIDConditional,
			PositionInExcel,
			MaxLength,
			WaterMarkText,
			IsDeleted,
			IsParent,
			DataTypeLength,
			ExcelTemplateColumnName,
			OrderPositionInExcel,
			TVPColumnName,
			isCognizant,
			ColumnShown,
			CreatedBy,
			CreatedDate,
			ModifiedBy,
			ModifiedOn 
	FROM MAS.ApplicationFieldMaster (NOLOCK) 
	WHERE IsDeleted=0
	END
	--END
ELSE if(@Mode='CheckApplicationFields' AND @isCognizant='1')

	BEGIN
	SELECT  ID,
			ColumnID,
			ColumnName,
			DataType,
			MandatoryID,
			ParentColumnIDConditional,
			PositionInExcel,
			MaxLength,
			WaterMarkText,
			IsDeleted,
			IsParent,
			DataTypeLength,
			ExcelTemplateColumnName,
			OrderPositionInExcel,
			TVPColumnName,
			isCognizant,
			ColumnShown,
			CreatedBy,
			CreatedDate,
			ModifiedBy,
			ModifiedOn 
	FROM [MAS].[ApplicationFieldMaster_Cognizant] (NOLOCK) 
	WHERE IsDeleted=0
	END
	
--Upload for AppInventory End

			SELECT ExcludedWordID AS Id,ExcludedWordName AS [ExcludeName] FROM MAS.ExcludedWords (NOLOCK) WHERE IsDeleted = 0

			SELECT ProjectID INTO #Projects FROM AVL.MAS_ProjectMaster (NOLOCK) WHERE CustomerID=@CustomerID

			SELECT COUNT(DISTINCT AttributeValueID) AS ExecCount FROM PP.ProjectAttributeValues(NOLOCK) WHERE AttributeID=3  AND IsDeleted=0
			AND ProjectID IN (SELECT ProjectID FROM #Projects) 
			DROP TABLE #Projects

	SELECT DISTINCT PAV.AttributeValueID as 'ProjectScopeID',
		Replace(Replace(Replace(REPLACE(REPLACE(ppav.AttributeValueName, 'Development', 'Development/Testing'),'Testing','Development/Testing'),'Development/Development/Testing','Development/Testing'),
		'Maintenance','Support'),'CIS','')
		as 'ProjectScopeName'
		into #AppScope
		FROM PP.ProjectAttributeValues PAV (NOLOCK)  
		JOIN MAS.PPAttributeValues ppav (NOLOCK)  on pav.AttributeID=ppav.AttributeID 
		AND PAV.AttributeValueID=ppav.AttributeValueID and ppav.IsDeleted=0 and ppav.AttributeID=1
		WHERE PAV.AttributeID=1
		AND PAV.ProjectID IN (SELECT ProjectID FROM AVL.MAS_ProjectMaster (NOLOCK) WHERE CustomerID=@CustomerID AND IsDeleted=0)
		AND PAV.IsDeleted=0

		select ProjectScopeName as ApplicationScope from #AppScope  where ProjectScopeName <>'' GROUP BY ProjectScopeName

		Drop table #AppScope

END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[dbo].[GetAppInventoryDetails] ', @ErrorMessage, 0,@CustomerId
		
	END CATCH  

END
