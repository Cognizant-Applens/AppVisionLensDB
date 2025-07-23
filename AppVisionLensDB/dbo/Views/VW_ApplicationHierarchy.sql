








--select * from [dbo].[VW_ApplicationHierarchy] where applicationid=3
CREATE VIEW [dbo].[VW_ApplicationHierarchy]
AS
With [LOB](ApplicationID,AppGroup,Portfolio,LoB)
AS
(
SELECT D.ApplicationID, 
    A.BusinessClusterBaseName AS AppGroup,
    B.BusinessClusterBaseName AS Portfolio,
    C.BusinessClusterBaseName AS LoB
FROM  AVL.APP_MAS_ApplicationDetails (NOLOCK) D
left join AVL.BusinessClusterMapping (NOLOCK) A ON D.SubBusinessClusterMapID = A.BusinessClusterMapID and A.IsDeleted=0 
left join AVL.BusinessClusterMapping (NOLOCK) B  ON  A.ParentBusinessClusterMapID = B.BusinessClusterMapID and B.IsDeleted=0 
left join  AVL.BusinessClusterMapping (NOLOCK) C ON B.ParentBusinessClusterMapID = C.BusinessClusterMapID and C.IsDeleted=0 
WHERE  D.IsActive = 1 
),
[RegulatoryBodyCTE](ApplicationID,RegulatoryBody)
AS
(
	select AD.ApplicationID,case when RegulatoryId = 8
	then OtherRegulatoryBody else RegulatoryBodyName end as RegulatoryBody
	from AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
	Left Join ADM.ALMApplicationDetails (NOLOCK) AA ON AA.ApplicationID=AD.ApplicationID and AD.IsActive=1
	Left Join ADM.AppRegulatoryBody (NOLOCK) ARB ON ARB.ApplicationId=AD.ApplicationID
    Left Join ADM.RegulatoryBody (NOLOCK) RB ON RB.ID=ARB.RegulatoryId
	where AD.IsActive=1-- and AD.applicationid=146378
	and AA.IsDeleted=0 and ARB.IsDeleted=0 and RB.IsDeleted=0
	group by AD.ApplicationID,RegulatoryId,OtherRegulatoryBody,RegulatoryBodyName
),
[RegulatoryBodyCTEgroup](ApplicationID,RegulatoryBody)
As
(
SELECT DISTINCT ST2.ApplicationID, 
    SUBSTRING(
        (
            SELECT ','+ST1.RegulatoryBody  AS [text()]
            FROM [RegulatoryBodyCTE] ST1
            WHERE ST1.ApplicationID = ST2.ApplicationID
            ORDER BY ST1.ApplicationID
            FOR XML PATH (''), TYPE
        ).value('text()[1]','nvarchar(max)'), 2, 1000) [RegulatoryBody]
FROM [RegulatoryBodyCTE] ST2
),
[UnitTestFramework](ApplicationID,UnitTestFrameWork)
AS
(
select AD.ApplicationID,case when UF.UnitTestFrameworkID=4 then UF.OtherUnitTestFramework 
else UFM.FrameWorkName end as UnitTestFrameWork
from AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
Left Join PP.MAP_UnitTestingFramework (NOLOCK) UF ON UF.ApplicationID=AD.ApplicationID
Left Join PP.MAS_UnitTestingFramework (NOLOCK) UFM ON UFM.UnitTestFrameworkID=UF.UnitTestFrameworkID
where AD.IsActive=1-- and AD.applicationid=146378
and UF.IsDeleted=0 and UFM.IsDeleted=0
	group by AD.ApplicationID,UFM.FrameWorkName,UF.UnitTestFrameworkID,UF.OtherUnitTestFramework 
),
[UnitTestFrameworkgroup](ApplicationID,UnitTestFrameWork)
As
(
SELECT DISTINCT ST2.ApplicationID, 
    SUBSTRING(
        (
            SELECT ','+ST1.UnitTestFrameWork  AS [text()]
            FROM [UnitTestFramework] ST1
            WHERE ST1.ApplicationID = ST2.ApplicationID
            ORDER BY ST1.ApplicationID
            FOR XML PATH (''), TYPE
        ).value('text()[1]','nvarchar(max)'), 2, 1000) [UnitTestFrameWork]
FROM [UnitTestFramework] ST2
),
[Supportwindow](ApplicationID,SupportWindow)
AS
(
select AD.ApplicationID,case when EA.SupportWindowID=6 then EA.OtherSupportWindow 
else SW.SupportWindowName end as SupportWindow
from AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
Left Join AVL.APP_MAS_Extended_ApplicationDetail (NOLOCK) EA ON EA.ApplicationID=AD.ApplicationID
Left Join AVL.APP_MAS_SupportWindow(NOLOCK) SW ON SW.SupportWindowID=EA.SupportWindowID
where AD.IsActive=1-- and AD.applicationid=146378 
and SW.ISdeleted=0 
group by AD.ApplicationID,EA.SupportWindowID,EA.OtherSupportWindow ,SW.SupportWindowName
),
[Supportwindowgroup](ApplicationID,SupportWindow)
As
(
SELECT DISTINCT ST2.ApplicationID, 
    SUBSTRING(
        (
            SELECT ','+ST1.SupportWindow  AS [text()]
            FROM [Supportwindow] ST1
            WHERE ST1.ApplicationID = ST2.ApplicationID
            ORDER BY ST1.ApplicationID
            FOR XML PATH (''), TYPE
        ).value('text()[1]','nvarchar(max)'), 2, 1000) [SupportWindow]
FROM [Supportwindow] ST2
),
[PrimaryTechnology](ApplicationID,PrimaryTechnology)
AS
(
select AD.ApplicationID,case when AD.[PrimaryTechnologyID]=97  then AD.OtherPrimaryTechnology 
else PT.[PrimaryTechnologyName] end as PrimaryTechnology
from AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
Left Join AVL.APP_MAS_PrimaryTechnology(NOLOCK)PT ON PT.PrimaryTechnologyID=AD.PrimaryTechnologyID and AD.IsActive=1 
where AD.IsActive=1-- and AD.applicationid=146378
and PT.IsDeleted=0
group by AD.ApplicationID,AD.[PrimaryTechnologyID],AD.OtherPrimaryTechnology ,PT.[PrimaryTechnologyName]
),
[PrimaryTechnologygroup](ApplicationID,PrimaryTechnology)
As
(
SELECT DISTINCT ST2.ApplicationID, 
    SUBSTRING(
        (
            SELECT ','+ST1.PrimaryTechnology  AS [text()]
            FROM [PrimaryTechnology] ST1
            WHERE ST1.ApplicationID = ST2.ApplicationID
            ORDER BY ST1.ApplicationID
            FOR XML PATH (''), TYPE
        ).value('text()[1]','nvarchar(max)'), 2, 1000) PrimaryTechnology
FROM [PrimaryTechnology] ST2
),
[FunctionalKnowledge](ApplicationID,FunctionalKnowledge)
AS
(
select AD.ApplicationID,case when AA.FunctionalKnowledge=0  then 'NA'
else FK.FunctionalKnowledgeName end as FunctionalKnowledge
from AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
Left Join ADM.ALMApplicationDetails (NOLOCK) AA ON AA.ApplicationID=AD.ApplicationID and AD.IsActive=1 
Left Join ADM.FunctionalKnowledge (NOLOCK) FK ON FK.ID=AA.FunctionalKnowledge
where AD.IsActive=1-- and AD.applicationid=146378
and AA.IsDeleted=0 and FK.IsDeleted=0
group by AD.ApplicationID,AA.FunctionalKnowledge,FK.FunctionalKnowledgeName

),
[FunctionalKnowledgegroup](ApplicationID,FunctionalKnowledge)
As
(
SELECT DISTINCT ST2.ApplicationID, 
    SUBSTRING(
        (
            SELECT ','+ST1.FunctionalKnowledge  AS [text()]
            FROM [FunctionalKnowledge] ST1
            WHERE ST1.ApplicationID = ST2.ApplicationID
            ORDER BY ST1.ApplicationID
            FOR XML PATH (''), TYPE
        ).value('text()[1]','nvarchar(max)'), 2, 1000) [FunctionalKnowledge]
FROM [FunctionalKnowledge] ST2
),
[ExecutionMethod](ApplicationID,ExecutionMethod)
AS
(
select AD.ApplicationID,case when AA.ExecutionMethod=15  then AA.OtherExecutionMethod
else PPA.AttributeValueName end as ExecutionMethod
from AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
Left Join ADM.ALMApplicationDetails (NOLOCK) AA ON AA.ApplicationID=AD.ApplicationID and AD.IsActive=1 
Left Join MAS.PPAttributeValues (NOLOCK)PPA ON PPA.AttributeValueID=AA.ExecutionMethod and PPA.AttributeID =3 and PPA.IsDeleted = 0
where AD.IsActive=1-- and AD.applicationid=146378
and AA.IsDeleted=0 and PPA.IsDeleted=0
group by AD.ApplicationID,AA.ExecutionMethod,AA.OtherExecutionMethod,PPA.AttributeValueName

),
[ExecutionMethodgroup](ApplicationID,ExecutionMethod)
As
(
SELECT DISTINCT ST2.ApplicationID, 
    SUBSTRING(
        (
            SELECT ','+ST1.ExecutionMethod  AS [text()]
            FROM [ExecutionMethod] ST1
            WHERE ST1.ApplicationID = ST2.ApplicationID
            ORDER BY ST1.ApplicationID
            FOR XML PATH (''), TYPE
        ).value('text()[1]','nvarchar(max)'), 2, 1000) [ExecutionMethod]
FROM [ExecutionMethod] ST2
),
[CloudServiceProvider](ApplicationID,CloudServiceProvider)
AS
(
select AD.ApplicationID,case when [CloudServiceProvider] = 13 or [CloudServiceProvider] = 24 then [OtherCloudServiceProvider]
else [CloudServiceProviderName] end as CloudServiceProvider
from AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
Left Join AVL.APP_MAS_InfrastructureApplication(NOLOCK)IA ON IA.ApplicationID=AD.ApplicationID and AD.IsActive=1 
Left Join AVL.APP_MAS_CloudServiceProvider (NOLOCK) CS ON CS.[CloudServiceProviderID]=IA.[CloudServiceProvider]
where AD.IsActive=1-- and AD.applicationid=146378
and IA.IsDeleted=0 and CS.IsDeleted=0
group by AD.ApplicationID,[CloudServiceProvider],[OtherCloudServiceProvider],[CloudServiceProviderName]
),
[CloudServiceProvidergroup](ApplicationID,CloudServiceProvider)
As
(
SELECT DISTINCT ST2.ApplicationID, 
    SUBSTRING(
        (
            SELECT ','+ST1.CloudServiceProvider  AS [text()]
            FROM [CloudServiceProvider] ST1
            WHERE ST1.ApplicationID = ST2.ApplicationID
            ORDER BY ST1.ApplicationID
            FOR XML PATH (''), TYPE
        ).value('text()[1]','nvarchar(max)'), 2, 1000) [CloudServiceProvider]
FROM [CloudServiceProvider] ST2
),
[GeographiesName](ApplicationID,GeographiesName)
AS
(
select ST1.ApplicationID,GS.GeographiesName
FROM AVL.APP_MAS_ApplicationDetails(NOLOCK)  ST1
Left Join ADM.AppGeographies (NOLOCK) AG ON AG.ApplicationId=ST1.ApplicationID
Left Join ADM.GeographiesSupported (NOLOCK) GS ON GS.ID=AG.GeographyId
where ST1.IsActive=1 and AG.IsDeleted=0 and GS.IsDeleted=0
group by ST1.ApplicationID,GeographiesName
),
[GeographiesNamegroup](ApplicationID,GeographiesName)
As
(
SELECT DISTINCT ST2.ApplicationID, 
    SUBSTRING(
        (
            SELECT ','+ST1.[GeographiesName]  AS [text()]
            FROM [GeographiesName] ST1
            WHERE ST1.ApplicationID = ST2.ApplicationID
            ORDER BY ST1.ApplicationID
            FOR XML PATH (''), TYPE
        ).value('text()[1]','nvarchar(max)'), 2, 1000) [GeographiesName]
FROM [GeographiesName] ST2
),
[Applicationscope](ApplicationID,Scopename)
AS
(
select AD.ApplicationID,AppS.ScopeName FROM AVL.APP_MAS_ApplicationDetails(NOLOCK)  AD
Left Join ADM.AppApplicationScope (NOLOCK) AAS ON AAS.ApplicationId=AD.ApplicationID and AD.IsActive=1 
Left Join ADM.ApplicationScope (NOLOCK) AppS ON AppS.ID=AAS.ApplicationScopeId
Where AD.IsActive=1 
),
[Applicationscopename](ApplicationID,Scopename)
As
(
SELECT DISTINCT ST2.ApplicationID, 
    SUBSTRING(
        (
            SELECT ','+ST1.Scopename  AS [text()]
            FROM [Applicationscope] ST1
            WHERE ST1.ApplicationID = ST2.ApplicationID
            ORDER BY ST1.ApplicationID
            FOR XML PATH (''), TYPE
        ).value('text()[1]','nvarchar(max)'), 2, 1000) [Applicationscope]
FROM [Applicationscope] ST2
)

 SELECT distinct AD.ApplicationID,
    ApplicationName,
    ApplicationCode,
    ApplicationShortName,
    SubBusinessClusterMapID,
   
    BC. BusinessCriticalityID,
   
    ApplicationDescription,
    ProductMarketName,
    CASE WHEN YEAR(ApplicationCommisionDate) = 9999 THEN NULL ELSE DATEADD(MINUTE,30,DATEADD(HOUR,5,ApplicationCommisionDate)) END AS ApplicationCommisionDate,
 
    DebtControlScopeID,
    OtherPrimaryTechnology,
    AD.IsActive,
    AD.CreatedBy,
    DATEADD(MINUTE,30,DATEADD(HOUR,5,AD.CreatedDate)) AS CreatedDate,
    AD.ModifiedBy,
     DATEADD(MINUTE,30,DATEADD(HOUR,5,AD.ModifiedDate)) AS ModifiedDate,
	BC.BusinessCriticalityName,
     DATEADD(MINUTE,30,DATEADD(HOUR,5,BC.ModifiedDate)) AS [BCM.ModifiedDate],
	IA.[ID],
    IA.[HostedEnvironmentID],
    --IA.[CloudServiceProvider] AS [CloudProvider],
    --IA.[OtherCloudServiceProvider] AS [OtherCloudServiceProvider],
    IA.[CloudModelID],
	CP.CloudModelName,
	HE.[HostedEnvironmentName] AS [APP_MAS_HostedEnvironment.HostedEnvironmentName],
	CS.[HostedEnvironmentName] AS [APP_MAS_CloudServiceProvider.HostedEnvironmentName],
    --CS.[CloudServiceProviderName],
	PT.[PrimaryTechnologyID],  
    PT.[PrimaryTechnologyName],
	OD.[ApplicationTypeID] AS [CodeOwnerShip],
    OD.[ApplicationTypename],
	RC.RegulatoryCompliantID,
    RC.RegulatoryCompliantName,
	AA.SourceCodeAvailability as SourceCodeAvailabilityID,
    AA.AvailabilityPercentage,
    AA.OtherExecutionMethod,
    AA.OtherRegulatoryBody,
    AA.IsRevenue,
    AA.IsAppAvailable,
    AA.ExecutionMethod as ExecutionMethodID,
  --  AA.FunctionalKnowledge as FunctionalKnowledgeID,
	--PPA.AttributeValueName AS ExecutionMethodName,
	--FK.FunctionalKnowledgeName,
	
    SCA.SourceCodeName as SourceCodeAvailabilityName,
	EA.UserBase,
    EA.SupportCategoryID,
    --EA.SupportWindowID,
    --EA.OtherSupportWindow,
	SC.SupportCategoryName,
	--SW.SupportWindowName,
	--ARB.RegulatoryId,
	--RB.RegulatoryBodyName,
	--AG.GeographyId,
	GNG.GeographiesName,
	AQA.NFRCaptured,
    AQA.TestingCoverage,
    AQA.RegressionTestCoverage,
    AQA.IsUnitTestAutomated,
    AQA.IsRegressionTest,
	--UF.UnitTestFrameworkID,
 --   UF.OtherUnitTestFramework,
	--UFM.FrameWorkName as UnitTestFrameWorkName,
	----AAS.ApplicationScopeId,
	AppS.Scopename as AppScopeName,
	L.AppGroup,
    L.Portfolio,
    L.LoB,
	RBG.RegulatoryBody,
	UFG.UnitTestFrameWork,
	SWG.SupportWindow,
	PTG.PrimaryTechnology,
	FKG.FunctionalKnowledge,
	EMG.ExecutionMethod,
	CSG.CloudServiceProvider,
	CASE WHEN AA.IsRevenue=1 then 'Yes' when AA.IsRevenue=0 then 'No'
	else 'NA' end as Revenue,
	CASE WHEN  AQA.IsUnitTestAutomated=1 then 'Yes' when AQA.IsUnitTestAutomated=0 then 'No'
	else 'NA' end as UnitTestAutomated,
	CASE WHEN    AQA.IsRegressionTest=1 then 'Yes' when   AQA.IsRegressionTest=0 then 'No'
	else 'NA' end as RegressionTest,
	CASE WHEN   AA.IsAppAvailable=1 then 'Yes' when  AA.IsAppAvailable=0 then 'No'
	else 'NA' end as AppAvailability
FROM AVL.APP_MAS_ApplicationDetails(NOLOCK) AD
Left Join AVL.APP_MAS_BusinessCriticality (NOLOCK) BC ON BC.BusinessCriticalityID=AD.BusinessCriticalityID and BC.IsDeleted=0
Left Join AVL.APP_MAS_InfrastructureApplication(NOLOCK)IA ON IA.ApplicationID=AD.ApplicationID and AD.IsActive=1 and IA.IsDeleted=0
Left Join MAS.MAS_CloudModelProvider(NOLOCK) CP ON CP.CloudModelID=IA.[CloudModelID] and CP.IsDeleted=0
Left Join AVL.APP_MAS_HostedEnvironment(NOLOCK) HE ON HE.HostedEnvironmentID=IA.[HostedEnvironmentID] and HE.IsDeleted=0
Left Join AVL.APP_MAS_CloudServiceProvider (NOLOCK) CS ON CS.[CloudServiceProviderID]=IA.[CloudServiceProvider] and CS.IsDeleted=0
Left Join AVL.APP_MAS_PrimaryTechnology(NOLOCK)PT ON PT.PrimaryTechnologyID=AD.PrimaryTechnologyID and AD.IsActive=1 and PT.IsDeleted=0
Left Join AVL.APP_MAS_OwnershipDetails (NOLOCK)OD ON OD.[ApplicationTypeID]=AD.CodeOwnerShip and AD.IsActive=1 and OD.IsDeleted=0
Left Join AVL.APP_MAS_RegulatoryCompliant (NOLOCK) RC ON RC.RegulatoryCompliantID=AD.RegulatoryCompliantID and AD.IsActive=1 and RC.IsDeleted=0
Left Join ADM.ALMApplicationDetails (NOLOCK) AA ON AA.ApplicationID=AD.ApplicationID and AD.IsActive=1 and AA.IsDeleted=0
--Left Join MAS.PPAttributeValues (NOLOCK)PPA ON PPA.AttributeValueID=AA.ExecutionMethod and PPA.AttributeID =3 and PPA.IsDeleted = 0
--Left Join ADM.FunctionalKnowledge (NOLOCK) FK ON FK.ID=AA.FunctionalKnowledge and FK.IsDeleted=0
Left Join ADM.SourceCodeAvailability (NOLOCK) SCA ON SCA.ID=AA.SourceCodeAvailability and SCA.IsDeleted=0
Left Join AVL.APP_MAS_Extended_ApplicationDetail (NOLOCK) EA ON EA.ApplicationID=AD.ApplicationID --and EA.IsDeleted=0
Left Join AVL.APP_MAS_SupportCategory (NOLOCK)SC ON SC.SupportCategoryID=EA.SupportCategoryID and SC.IsDeleted=0
--Left Join AVL.APP_MAS_SupportWindow(NOLOCK) SW ON SW.SupportWindowID=EA.SupportWindowID and SW.IsDeleted=0
--Left Join ADM.AppRegulatoryBody (NOLOCK) ARB ON ARB.ApplicationId=AD.ApplicationID and ARB.IsDeleted=0
--Left Join ADM.RegulatoryBody (NOLOCK) RB ON RB.ID=ARB.RegulatoryId and RB.IsDeleted=0
--Left Join ADM.AppGeographies (NOLOCK) AG ON AG.ApplicationId=AD.ApplicationID and AG.IsDeleted=0
--Left Join ADM.GeographiesSupported (NOLOCK) GS ON GS.ID=AG.GeographyId and GS.IsDeleted=0
Left Join PP.ApplicationQualityAttributes (NOLOCK)AQA ON AQA.ApplicationID=AD.ApplicationID and AQA.IsDeleted=0
--Left Join PP.MAP_UnitTestingFramework (NOLOCK) UF ON UF.ApplicationID=AD.ApplicationID and UF.IsDeleted=0
--Left Join PP.MAS_UnitTestingFramework (NOLOCK) UFM ON UFM.UnitTestFrameworkID=UF.UnitTestFrameworkID and UFM.IsDeleted=0
--Left Join ADM.AppApplicationScope (NOLOCK) AAS ON AAS.ApplicationId=AD.ApplicationID and AD.IsActive=1 and AAS.IsDeleted=0
Left Join [Applicationscopename]  AppS ON AppS.ApplicationId=AD.ApplicationID
Left JOIN [LOB] L ON L.ApplicationID=AD.ApplicationID
Left Join [RegulatoryBodyCTEgroup] RBG ON RBG.ApplicationID=AD.ApplicationID
Left Join [UnitTestFrameworkgroup] UFG ON UFG.ApplicationID=AD.ApplicationID
Left Join [Supportwindowgroup] SWG ON SWG.ApplicationID=AD.ApplicationID
Left Join [PrimaryTechnologygroup] PTG ON PTG.ApplicationID=AD.ApplicationID
Left Join [FunctionalKnowledgegroup] FKG ON FKG.ApplicationID=AD.ApplicationID
Left Join [ExecutionMethodgroup] EMG ON EMG.ApplicationID=AD.ApplicationID
Left Join [CloudServiceProvidergroup] CSG ON CSG.ApplicationID=AD.ApplicationID
Left Join [GeographiesNamegroup] GNG ON GNG.ApplicationID=AD.ApplicationID

where AD.IsActive=1 


