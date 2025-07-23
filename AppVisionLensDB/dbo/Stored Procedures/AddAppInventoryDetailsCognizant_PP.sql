/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/
CREATE PROCEDURE [dbo].[AddAppInventoryDetailsCognizant_PP] -- '827309', '7097', '10337'      
 @CognizantId nVARCHAR(50) =null,        
 @CustomerId int=Null,        
 @ProjectID bigint=null        
AS        
BEGIN        
BEGIN TRY        
BEGIN TRAN        
         
 SET NOCOUNT ON;        
 --select * from mas.AppInventoryUpload      
   
  SELECT projectid, Associateid, Esaprojectid into #tempAssociatedetails   
  from RLE.VW_ProjectLevelRoleAccessDetails (NOLOCK)  
  WHERE Associateid = @CognizantId  
            
IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp         
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
,BusinessCriticalityID BigINT NULL        
,BusinessCriticalityName VARCHAR(max) NULL        
,PrimaryTechnologyID BIGINT NULL        
,PrimaryTechnologyName VARCHAR(max) NULL        
,ApplicationDescription nVARCHAR(200) NULL        
,ProductMarketName nVARCHAR(max) NULL        
,ApplicationCommisionDate DATETIME         
,RegulatoryCompliantID BIGINT NULL        
,RegulatoryCompliantName VARCHAR(MAX) NULL        
,DebtControlScopeID BIGINT NULL        
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
 CASE WHEN Active='No' THEN 0 ELSE 1 END Active,        
 OtherTechnology,        
 OtherServiceProvider,        
 OtherWindow        
FROM MAS.AppInventoryUpload (NOLOCK)      
        
select a.ApplicationID        
 into #app1         
 from avl.APP_MAS_ApplicationDetails a (NOLOCK) 
 join avl.BusinessClusterMapping b (NOLOCK) on a.SubBusinessClusterMapID=b.BusinessClusterMapID         
 and b.IsHavingSubBusinesss='0'         
  where CustomerID=@CustomerId         
        
SELECT 'SubBusinessClusterMapID'        
        
--SubBusinessClusterMapID        
UPDATE A SET A.SubBusinessClusterMapID=BCM.BusinessClusterMapID        
FROM #Temp A INNER JOIN AVL.BusinessClusterMapping BCM (NOLOCK)       
ON A.SubBusinessClusterName=BCM.BusinessClusterBaseName         
WHERE BCM.IsHavingSubBusinesss=0 AND A.CustomerId =BCM.CustomerID and BCM.isdeleted='0'        
SELECT 'ApplicationTypeID'        
        
--ApplicationTypeID        
UPDATE A SET A.ApplicationTypeID=C.ApplicationTypeID        
FROM #Temp A INNER JOIN AVL.APP_MAS_OwnershipDetails C (NOLOCK)       
ON A.ApplicationTypename=C.ApplicationTypename         
WHERE A.CustomerId=@CustomerId         
        
SELECT 'BusinessCriticalityID'        
--BusinessCriticalityID        
UPDATE A SET A.BusinessCriticalityID=D.BusinessCriticalityID        
FROM #Temp A INNER JOIN AVL.APP_MAS_BusinessCriticality D (NOLOCK)        
ON A.BusinessCriticalityName=D.BusinessCriticalityName         
WHERE A.CustomerId=@CustomerId        
        
SELECT 'PrimaryTechnologyID'        
--PrimaryTechnologyID        
UPDATE A SET A.PrimaryTechnologyID=E.PrimaryTechnologyID        
FROM #Temp A INNER JOIN AVL.APP_MAS_PrimaryTechnology E (NOLOCK)       
ON A.PrimaryTechnologyName=E.PrimaryTechnologyName        
WHERE A.CustomerId=@CustomerId        
        
SELECT 'RegulatoryCompliantID'        
--RegulatoryCompliantID        
UPDATE A SET A.RegulatoryCompliantID=F.RegulatoryCompliantID        
FROM #Temp A INNER JOIN AVL.APP_MAS_RegulatoryCompliant F (NOLOCK)       
ON A.RegulatoryCompliantName=F.RegulatoryCompliantName         
WHERE A.CustomerId=@CustomerId        
        
select 'DebtControlScopeID'        
--DebtControlScopeID        
UPDATE A SET A.DebtControlScopeID=G.DebtcontrolScopeID        
FROM #Temp A INNER JOIN AVL.APP_MAS_DebtcontrolScope G (NOLOCK)       
ON A.DebtcontrolScopeName=G.DebtcontrolScopeName         
WHERE A.CustomerId=@CustomerId        
        
select 'SupportWindowID'        
--SupportWindowID        
UPDATE A SET A.SupportWindowID=H.SupportWindowID        
FROM #Temp A INNER JOIN AVL.APP_MAS_SupportWindow H (NOLOCK)       
ON A.SupportWindowName=H.SupportWindowName         
WHERE A.CustomerId=@CustomerId        
        
select 'SupportCategoryID'        
--SupportCategoryID        
UPDATE A SET A.SupportCategoryID=I.SupportCategoryID        
FROM #Temp A INNER JOIN AVL.APP_MAS_SupportCategory I (NOLOCK)       
ON A.SupportCategoryName=I.SupportCategoryName         
WHERE A.CustomerId=@CustomerId        
        
select 'HostedEnvironmentID'        
--HostedEnvironmentID        
UPDATE A SET A.HostedEnvironmentID=J.HostedEnvironmentID        
FROM #Temp A INNER JOIN AVL.APP_MAS_HostedEnvironment J (NOLOCK)       
ON A.HostedEnvironmentName=J.HostedEnvironmentName         
WHERE A.CustomerId=@CustomerId        
        
select 'CloudServiceProviderID'        
UPDATE A SET A.CloudServiceProviderID=J.CloudServiceProviderID        
FROM #Temp A INNER JOIN AVL.APP_MAS_CloudServiceProvider J (NOLOCK)       
ON A.CloudServiceProvider=J.CloudServiceProviderName         
WHERE A.CustomerId=@CustomerId        
        
UPDATE A SET A.CloudModelID=J.CloudModelID        
FROM #Temp A INNER JOIN MAS.MAS_CloudModelProvider J  (NOLOCK)      
ON A.CloudModelName=J.CloudModelName         
WHERE A.CustomerId=@CustomerId        
        
select t.ApplicationID, t.ApplicationName        
 ,t.ApplicationCode,t.ApplicationShortName,t.SubBusinessClusterMapID,t.SubBusinessClusterName,t.ApplicationTypeID,t.ApplicationTypename,        
 t.BusinessCriticalityID,t.BusinessCriticalityName,t.PrimaryTechnologyID,t.PrimaryTechnologyName,t.ApplicationDescription,        
 t.ProductMarketName,t.ApplicationCommisionDate,t.RegulatoryCompliantID,t.RegulatoryCompliantName,        
 t.DebtControlScopeID,t.DebtcontrolScopeName,t.UserBase,t.SupportWindowID,t.SupportWindowName,        
 t.Incallwdgreen,t.Infraallwdgreen,t.Infoallwdgreen,t.Incallwdamber,t.Infraallwdamber,t.Infoallwdamber,     t.SupportCategoryID,t.SupportCategoryName,t.ProcessingTypeID,t.ProcessingTypeName,t.VMName,t.OperatingSystem,        
 t.ServerConfiguration,t.ServerOwner,t.LicenseDetails,t.DatabaseVersion,t.HostedEnvironmentID,t.HostedEnvironmentName,        
 t.CloudServiceProviderID,t.CloudServiceProvider,        
 t.CloudModelName,t.CloudModelID,        
 t.AppPlatform,t.CustomerId,t.isCognizant,t.IsActive,t.OtherTechnology,t.OtherServiceProvider,t.OtherWindow        
into #existingAppDetails         
from #Temp t (NOLOCK)       
join avl.APP_MAS_ApplicationDetails mas (NOLOCK)        
 on t.ApplicationName=mas.ApplicationName         
 and t.SubBusinessClusterMapID=mas.SubBusinessClusterMapID join avl.BusinessClusterMapping bcm on bcm.CustomerID=@CustomerId        
         
select * into #newAppDetails from(        
select * from #Temp  (NOLOCK)      
EXCEPT        
select * from #existingAppDetails (NOLOCK))new;        
        
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
  FROM #existingAppDetails T INNER JOIN AVL.APP_MAS_ApplicationDetails APD  (NOLOCK)      
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
  FROM #existingAppDetails T INNER JOIN AVL.APP_MAS_ApplicationDetails AD  (NOLOCK)      
  ON T.ApplicationName=AD.ApplicationName AND T.SubBusinessClusterMapID=AD.SubBusinessClusterMapID        
  INNER JOIN AVL.APP_MAS_Extended_ApplicationDetail ExAPD        
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
  FROM #existingAppDetails T INNER JOIN AVL.APP_MAS_ApplicationDetails AD (NOLOCK)       
  ON T.ApplicationName=AD.ApplicationName AND T.SubBusinessClusterMapID=AD.SubBusinessClusterMapID        
  INNER JOIN AVL.APP_MAS_InfrastructureApplication Inf        
  ON AD.ApplicationID=Inf.ApplicationID         
        
  --- Appliction ISActive Update        
          
  UPDATE AD SET AD.IsActive = EA.IsActive ,        
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
   #tempAssociatedetails   ECPRBM  (NOLOCK)       
  JOIN        
    AVl.MAS_ProjectMaster PM (NOLOck) ON PM.ESAProjectID=ECPRBM.ESAProjectId      
 JOIN AVl.Customer C (nolock) ON C.CustomerId=PM.Customerid      
  WHERE         
    C.CustomerId=@CustomerId AND PM.CustomerID=@CustomerId AND PM.IsDeleted=0        
        
/******************/        
        
 DECLARE @Count int         
 Set @Count= (SELECT COUNT(*) FROM #newAppDetails (NOLOCK))        
         
  /***PROGRESS****/        
IF @Count>0        
BEGIN        
IF EXISTS(        
   SELECT         
     1         
   FROM         
     AVL.PRJ_ConfigurationProgress (NOLOCK)        
   WHERE         
     ScreenID=1 AND CustomerID=@CustomerID)        
BEGIN        
IF NOT EXISTS(        
SELECT 1 FROM AVL.APP_MAS_ApplicationDetails AD (NOLOCK) JOIN Avl.BusinessClusterMapping BC (NOLOCK)       
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
        
CREATE TABLE #NewAppCogDetails        
(        
ApplicationID BIGINT ,        
ApplicationName NVARCHAR(100),        
CustomerID BIGINT        
)        
        
 WHILE (@Count>0)        
 BEGIN        
         
 select * into #AppInvtopTemp FROM (SELECT top 1 * from #newAppDetails (NOLOCK)) A        
        
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
  ,DebtControlScopeID        
  ,IsActive        
  ,@CognizantId        
  --,575633        
  ,Getdate()        
  ,NULL        
  ,NULL        
  ,OtherTechnology        
  from #AppInvtopTemp  (NOLOCK)        
           
          
  DECLARE @ApplicationID BigINT        
  DECLARE @ApplicationName VARCHAR(MAX)        
        
 SET @ApplicationID=(SELECT @@IDENTITY)        
 SET @ApplicationName=(SELECT TOP 1 ApplicationName FROM #AppInvtopTemp (NOLOCK))        
        
 -- New Application List         
 INSERT INTO #NewAppCogDetails(ApplicationID,ApplicationName,CustomerID)        
 SELECT @ApplicationID,@ApplicationName,@CustomerId        
        
         
UPDATE A SET A.ApplicationID=@ApplicationID        
FROM #AppInvtopTemp A (NOLOCK)        
WHERE A.CustomerId=@CustomerId AND A.ApplicationName=@ApplicationName        
/*projectmapping***/        
--DECLARE @ProjectID bigint;        
        
--****Existing flow get projectId from view        
--SELECT         
--  TOP 1 @ProjectID=PM.ProjectID        
--   FROM         
--   [AVL].[VW_EmployeeCustomerProjectRoleBUMapping] ECPRBM         
--  JOIN        
--    AVl.MAS_ProjectMaster PM ON PM.ProjectID=ECPRBM.ProjectId        
--  WHERE         
--    ECPRBM.CustomerId=@CustomerId AND PM.CustomerID=@CustomerId AND PM.IsDeleted=0        
        
            
        
IF NOT EXISTS(SELECT 1 FROM AVL.APP_MAP_ApplicationProjectMapping AP (NOLOCK) WHERE AP.ProjectID=@ProjectID and AP.ApplicationID=@ApplicationID)        
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
      SELECT @ProjectID,@ApplicationID,0,@CognizantId,GETDATE()         
      FROM #AppInvtopTemp (NOLOCK)        
      WHERE ApplicationID=@ApplicationID and IsActive=1;        
         
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
  from #AppInvtopTemp (NOLOCK)       
          
          
        
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
 from #AppInvtopTemp (NOLOCK);        
         
        
        
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
        
        
update t set t.applicationID=mas.applicationID         
from         
#existingAppDetails t        
join avl.APP_MAS_ApplicationDetails mas (NOLOCK)        
 on t.ApplicationName=mas.ApplicationName         
 and t.SubBusinessClusterMapID=mas.SubBusinessClusterMapID         
 join avl.BusinessClusterMapping bcm (NOLOCK)        
 on bcm.CustomerID=@CustomerId        
        
  -------------------------------------------------------------------        
  ---- INSERTING EXISTING APPLICATIONS INTO ADM TABLES -----        
  -------------------------------------------------------------------        
  SELECT ApplicationID INTO #newADMAppDetails FROM(        
  SELECT ApplicationID FROM #existingAppDetails (NOLOCK)      
  EXCEPT        
  SELECT ApplicationID FROM ADM.ALMApplicationDetails (NOLOCK))newap;        
        
  IF EXISTS (SELECT 1 FROM #newADMAppDetails (NOLOCK))        
  BEGIN          
        
          
   INSERT INTO ADM.ALMApplicationDetails(ApplicationID,IsRevenue,IsAnySIVendor,FunctionalKnowledge,        
           ExecutionMethod,OtherExecutionMethod,SourceCodeAvailability,        
           OtherRegulatoryBody,IsAppAvailable,AvailabilityPercentage,IsDeleted,        
           CreatedBy,CreatedDate)        
   SELECT ND.ApplicationID,        
   CASE         
    WHEN LOWER( b.IsRevenue) ='yes'  THEN 1        
    WHEN LOWER(b.IsRevenue) ='no'  THEN 0 END,        
   --CASE         
   -- WHEN LOWER( b.IsAnySIVendor) ='yes'  THEN 1        
   -- WHEN  LOWER(b.IsAnySIVendor) ='no'  THEN 0 END,        
   NULL,        
   F.ID,EM.ID, b.OtherExecutionMethod,SC.ID,b.OtherRegulatoryBody,        
   CASE         
    WHEN LOWER( b.IsAppAvailable) ='yes'  THEN 1        
    WHEN  LOWER(b.IsAppAvailable) ='no'  THEN 0        
    WHEN  LOWER(b.IsAppAvailable) ='na'  THEN 2 END,        
   b.AvailabilityPercent,0, @CognizantId,GETDATE()        
   FROM #newADMAppDetails ND         
   JOIN avl.APP_MAS_ApplicationDetails NA (NOLOCK) on ND.ApplicationID=NA.ApplicationID        
   JOIN [ADM].[AppInventoryCognizant_Upload] b (NOLOCK) on NA.ApplicationName=b.ApplicationName        
   LEFT JOIN ADM.FunctionalKnowledge F (NOLOCK) on b.FunctionalKnowledge=F.FunctionalKnowledgeName AND F.isdeleted=0        
   --LEFT JOIN [ADM].[ExecutionMethod] EM on b.ExecutionMethod=EM.ExecutionMethodName AND EM.isdeleted=0        
   LEFT JOIN (SELECT PPA.AttributeValueID AS ID, PPA.AttributeValueName AS ExecutionMethodName from Mas.PPAttributeValues (NOLOCK) PPA        
    INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0        
    WHERE AttributeName = 'ExecutionMethod') EM on b.ExecutionMethod=EM.ExecutionMethodName        
   LEFT JOIN [ADM].[SourceCodeAvailability] SC (NOLOCK) on B.SourceCodeAvailability=SC.[SourceCodeName] AND SC.IsDeleted=0        
   WHERE b.CustomerId=@CustomerId        
        
  END        
          
  DROP TABLE #newADMAppDetails        
  -------------------------------------------------------------------        
  ---- UPDATING EXISTING APPLICATIONS END -----        
  -------------------------------------------------------------------        
          
 ---------------------------------------------------------------------     
 --- INSERTING NEW APPLICATONS INTO ADM table  -----------------------        
 ---------------------------------------------------------------------        
 IF EXISTS (SELECT 1 FROM #NewAppCogDetails (NOLOCK))        
 BEGIN        
        
        
        
        
  INSERT INTO ADM.ALMApplicationDetails(ApplicationID,IsRevenue,IsAnySIVendor,FunctionalKnowledge,        
           ExecutionMethod,OtherExecutionMethod,SourceCodeAvailability,        
           OtherRegulatoryBody,IsAppAvailable,AvailabilityPercentage,IsDeleted,        
           CreatedBy,CreatedDate)        
   SELECT ND.ApplicationID,        
   CASE         
    WHEN LOWER( b.IsRevenue) ='yes'  THEN 1        
    WHEN LOWER(b.IsRevenue) ='no'  THEN 0 END,        
   --CASE         
   -- WHEN LOWER( b.IsAnySIVendor) ='yes'  THEN 1        
   -- WHEN  LOWER(b.IsAnySIVendor) ='no'  THEN 0 END,        
   NULL,        
   F.ID,EM.ID, b.OtherExecutionMethod,SC.ID,b.OtherRegulatoryBody,        
   CASE         
    WHEN LOWER( b.IsAppAvailable) ='yes'  THEN 1        
    WHEN  LOWER(b.IsAppAvailable) ='no'  THEN 0        
    WHEN  LOWER(b.IsAppAvailable) ='na'  THEN 2 END,        
   b.AvailabilityPercent,0, @CognizantId,GETDATE()        
   FROM #NewAppCogDetails ND  (NOLOCK)       
   --JOIN #newAppDetails NA on ND.ApplicationName=NA.ApplicationName        
   JOIN [ADM].[AppInventoryCognizant_Upload] b (NOLOCK) on ND.ApplicationName=b.ApplicationName        
   LEFT JOIN ADM.FunctionalKnowledge F (NOLOCK) on b.FunctionalKnowledge=F.FunctionalKnowledgeName AND F.isdeleted=0        
   --LEFT JOIN [ADM].[ExecutionMethod] EM on b.ExecutionMethod=EM.ExecutionMethodName AND EM.isdeleted=0        
   LEFT JOIN (SELECT PPA.AttributeValueID AS ID, PPA.AttributeValueName AS ExecutionMethodName from Mas.PPAttributeValues (NOLOCK) PPA        
    INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0        
    WHERE AttributeName = 'ExecutionMethod') EM on b.ExecutionMethod=EM.ExecutionMethodName        
   LEFT JOIN [ADM].[SourceCodeAvailability] SC (NOLOCK) on B.SourceCodeAvailability=SC.[SourceCodeName] AND SC.IsDeleted=0        
   WHERE b.CustomerId=@CustomerId        
           
         
         
 END         
 ---------------------------------------------------------------------        
 --- INSERTING NEW APPLICATONS INTO ADM table END --------------------        
 ---------------------------------------------------------------------        
        
        
 ----------------        
        
        
 -------------added----------------       
  -- Application Scope Part         
    select a.ApplicationID,a.ApplicationName        
 into #app         
 from avl.APP_MAS_ApplicationDetails(nolock) a         
 join avl.BusinessClusterMapping b on a.SubBusinessClusterMapID=b.BusinessClusterMapID         
 and b.IsHavingSubBusinesss='0'         
    where b.CustomerID=@CustomerId        
        
        
   SELECT d.ApplicationId,b.ApplicationName,aac.ScopeName,aac.ID as 'ApplicationScopeID' into #AppScope         
   FROM #app d        
   join [ADM].[AppInventoryCognizant_Upload] b (NOLOCK) on d.ApplicationName=b.ApplicationName        
   join [ADM].ApplicationScope aac (NOLOCK) on aac.ScopeName in (SELECT Item FROM dbo.Split(b.ApplicationScope, ','))        
   where b.CustomerID=@CustomerId        
   and aac.IsDeleted='0'         
        
        
   IF EXISTS(SELECT 1 FROM #AppScope (NOLOCK))        
   BEGIN         
        
     delete from ADM.AppApplicationScope where ApplicationId in (select applicationid from #AppScope (NOLOCK))        
            
    INSERT INTO ADM.AppApplicationScope(ApplicationId,ApplicationScopeId,IsDeleted,CreatedBy,CreatedDate)        
    SELECT ApplicationId,ApplicationScopeID,0,'System',GETDATE() FROM #AppScope  (NOLOCK)       
    where ApplicationID not in (select ApplicationID from ADM.AppApplicationScope (NOLOCK))        
        
   END        
   DROP TABLE #AppScope        
        
   -- Geographic part         
     SELECT d.ApplicationId,b.ApplicationName,aac.GeographiesName,aac.ID as 'GeographiesSupportedID' into #AppGeographic         
    FROM         
     #app d         
    JOIN [ADM].[AppInventoryCognizant_Upload] b (NOLOCK) on d.ApplicationName=b.ApplicationName        
    JOIN [ADM].GeographiesSupported aac (NOLOCK) on aac.GeographiesName in (SELECT Item FROM dbo.Split(b.GeographiesSupported, ','))        
    WHERE b.CustomerID=@customerid        
    AND aac.IsDeleted='0'          
           
    IF EXISTS(SELECT 1 FROM #AppGeographic (NOLOCK))        
    BEGIN         
           
    DELETE FROM ADM.AppGeographies WHERE ApplicationId in (SELECT ApplicationID FROM #AppGeographic (NOLOCK))        
           
    INSERT INTO ADM.AppGeographies(ApplicationId,GeographyId,IsDeleted,CreatedBy,CreatedDate)        
     SELECT ApplicationID,GeographiesSupportedID,0,'System',GETDATE() FROM #AppGeographic  (NOLOCK)      
     where applicationid not in(select applicationid from ADM.AppGeographies (NOLOCK))         
           
   END        
           
   DROP TABLE #AppGeographic        
        
  --Regulatory Body Part        
  SELECT d.ApplicationId,b.ApplicationName,aac.RegulatoryBodyName,aac.ID as 'RegulatoryBodyID' into #AppRegulatoryBody         
  FROM         
   #app d         
  join [ADM].[AppInventoryCognizant_Upload] b (NOLOCK) on d.ApplicationName=b.ApplicationName        
  join [ADM].RegulatoryBody aac (NOLOCK) on aac.RegulatoryBodyName in (SELECT Item FROM dbo.Split(b.RegulatoryBody, ','))        
  where b.CustomerID=@customerid        
  and aac.IsDeleted='0'         
        
  IF EXISTS(SELECT 1 FROM #AppRegulatoryBody (NOLOCK))        
  BEGIN            
    DELETE FROM ADM.AppRegulatoryBody WHERE ApplicationId in (SELECT ApplicationID FROM #AppRegulatoryBody)        
        
    INSERT INTO ADM.AppRegulatoryBody(ApplicationId,RegulatoryId,IsDeleted,CreatedBy,CreatedDate)        
    SELECT ApplicationID,RegulatoryBodyID,0,'System',GETDATE() FROM #AppRegulatoryBody  (NOLOCK)      
    where applicationid not in(select applicationid from ADM.AppRegulatoryBody (NOLOCK))        
  END        
        
  DROP TABLE #AppRegulatoryBody        
      
      
      
      
         
  select s.ID,s.ApplicationName,s.ApplicationScope,s.IsRevenue,s.IsAnySIVendor,s.GeographiesSupported,s.FunctionalKnowledge,s.ExecutionMethod        
,s.OtherExecutionMethod,s.SourceCodeAvailability,s.RegulatoryBody,s.OtherRegulatoryBody,s.IsAppAvailable,s.AvailabilityPercent,s.IsCognizant        
,s.CustomerId,s.IsValid,s.IsDeleted,s.CreatedBy,s.CreatedDate,s.ModifiedBy        
,s.ModifiedDate,a.ApplicationID into #ALMApplicationTemp from [ADM].[AppInventoryCognizant_Upload] s (NOLOCK) join #app a on s.ApplicationName=a.ApplicationName        
          
   declare @CustomerCount int=Null        
   select @CustomerCount =count(AM.ApplicationID) from  #ALMApplicationTemp AM where ApplicationID           
   not in (select ApplicationID from ADM.ALMApplicationDetails)        
   If (@CustomerCount >0)        
   Begin         
   INSERT INTO ADM.ALMApplicationDetails(ApplicationID,IsRevenue,IsAnySIVendor,FunctionalKnowledge,        
           ExecutionMethod,OtherExecutionMethod,SourceCodeAvailability,        
           OtherRegulatoryBody,IsAppAvailable,AvailabilityPercentage,IsDeleted,        
           CreatedBy,CreatedDate)        
   SELECT ND.ApplicationID,        
   CASE         
    WHEN LOWER( b.IsRevenue) ='yes'  THEN 1        
    WHEN LOWER(b.IsRevenue) ='no'  THEN 0 END,        
   --CASE         
   -- WHEN LOWER( b.IsAnySIVendor) ='yes'  THEN 1        
   -- WHEN  LOWER(b.IsAnySIVendor) ='no'  THEN 0 END,        
   NULL,        
   F.ID,EM.ID, b.OtherExecutionMethod,SC.ID,b.OtherRegulatoryBody,        
   CASE         
    WHEN LOWER( b.IsAppAvailable) ='yes'  THEN 1        
    WHEN  LOWER(b.IsAppAvailable) ='no'  THEN 0        
    WHEN  LOWER(b.IsAppAvailable) ='na'  THEN 2 END,        
   b.AvailabilityPercent,0, ND.CreatedBy,GETDATE()        
   FROM #ALMApplicationTemp ND         
   --JOIN #newAppDetails NA on ND.ApplicationName=NA.ApplicationName        
   JOIN [ADM].[AppInventoryCognizant_Upload] b (NOLOCK) on ND.ApplicationName=b.ApplicationName        
   LEFT JOIN ADM.FunctionalKnowledge F (NOLOCK) on b.FunctionalKnowledge=F.FunctionalKnowledgeName AND F.isdeleted=0        
   --LEFT JOIN [ADM].[ExecutionMethod] EM on b.ExecutionMethod=EM.ExecutionMethodName AND EM.isdeleted=0        
   LEFT JOIN (SELECT PPA.AttributeValueID AS ID, PPA.AttributeValueName AS ExecutionMethodName from Mas.PPAttributeValues (NOLOCK) PPA        
    INNER JOIN Mas.PPAttributes (NOLOCK) PA ON PA.AttributeID = PPA.AttributeID AND PA.IsDeleted = 0 AND PPA.IsDeleted = 0        
    WHERE AttributeName = 'ExecutionMethod') EM on b.ExecutionMethod=EM.ExecutionMethodName        
   LEFT JOIN [ADM].[SourceCodeAvailability] SC on B.SourceCodeAvailability=SC.[SourceCodeName] AND SC.IsDeleted=0        
   WHERE b.CustomerId=@CustomerId        
   End        
        
         
 ----------------        
 update A set A.NFRCaptured= b.NFRCaptured,        
A.IsUnitTestAutomated = CASE         
    WHEN LOWER( b.IsUnitTestAutomated) ='yes'  THEN 1        
    WHEN  LOWER(b.IsUnitTestAutomated) ='no'  THEN 0 END,        
           
A.TestingCoverage = b.TestingCoverage,        
A.IsRegressionTest=CASE         
    WHEN LOWER( b.IsRegressionTest) ='yes'  THEN 1        
    WHEN  LOWER(b.IsRegressionTest) ='no'  THEN 0 end,        
A.RegressionTestCoverage=b.RegressionTestCoverage,        
A.IsDeleted='0',a.ModifiedBy='System',a.ModifiedOn=GETDATE()        
from pp.ApplicationQualityAttributes A (NOLOCK)        
join #app  ND on A.applicationid=ND.ApplicationID        
join [ADM].[AppInventoryUnitTestingCognizant_Upload] b (NOLOCK) on  ND.ApplicationName=b.ApplicationName        
WHERE b.CustomerId=@CustomerId         
        
select * into #Newappupload from [ADM].[AppInventoryUnitTestingCognizant_Upload] (NOLOCK) where ApplicationName not in         
(SELECT ApplicationName FROM #app  A join pp.ApplicationQualityAttributes B (NOLOCK) on A.Applicationid=b.applicationid )        
and CustomerId=@CustomerId         
        
Insert into pp.ApplicationQualityAttributes (ApplicationID,NFRCaptured,IsUnitTestAutomated,TestingCoverage,IsRegressionTest,        
 RegressionTestCoverage,IsDeleted,CreatedBy,CreatedOn)        
        
 SELECT ND.ApplicationID,b.NFRCaptured,        
   CASE         
    WHEN LOWER( b.IsUnitTestAutomated) ='yes'  THEN 1        
    WHEN  LOWER(b.IsUnitTestAutomated) ='no'  THEN 0 END,        
   b.TestingCoverage,        
   CASE         
    WHEN LOWER( b.IsRegressionTest) ='yes'  THEN 1        
    WHEN  LOWER(b.IsRegressionTest) ='no'  THEN 0 end,        
   b.RegressionTestCoverage,0, 'System',GETDATE()        
   FROM #app ND         
   JOIN  #Newappupload b on ND.ApplicationName=b.ApplicationName        
   WHERE b.CustomerId=@CustomerId        
        
        
        
select d.ApplicationId,b.ApplicationName,b.OtherUnitTestFramework as 'OtherUnitTestFramework',aac.UnitTestFrameworkID as 'UnitTestFrameworkID' into #tempUnitTestingData         
 from         
 --ADM.ALMApplicationDetails a         
 #app d --on a.ApplicationID=d.ApplicationID        
 join [ADM].[AppInventoryUnitTestingCognizant_Upload] b (NOLOCK) on d.ApplicationName=b.ApplicationName        
 join [PP].[MAS_UnitTestingFramework] aac (NOLOCK) on aac.FrameWorkName in (SELECT Item FROM dbo.Split(b.UnitTestFrameworkID, ','))        
 --WHERE b.CustomerId=@CustomerId        
 and aac.IsDeleted='0'         
        
 IF EXISTS(SELECT 1 FROM #tempUnitTestingData)         
 BEGIN        
        
  delete from [PP].[MAP_UnitTestingFramework] where applicationid in (select applicationid from #tempUnitTestingData)      
        
        
 INSERT INTO [PP].[MAP_UnitTestingFramework](ApplicationId,UnitTestFrameworkID,OtherUnitTestFramework,IsDeleted,CreatedBy,CreatedOn)        
 SELECT aa.ApplicationId,aa.UnitTestFrameworkID,aa.OtherUnitTestFramework,0,'System',GETDATE() FROM #tempUnitTestingData aa         
 where aa.ApplicationID not in (select ApplicationID from [PP].[MAP_UnitTestingFramework] (NOLOCK))        
        
 -- DROP Application Scope         
 --DELETE FROM [PP].[MAP_UnitTestingFramework] WHERE ApplicationId in (SELECT ApplicationID FROM #app)        
        
 ---- Updating AppApplicationScope         
 --INSERT INTO [PP].[MAP_UnitTestingFramework](ApplicationId,UnitTestFrameworkID,OtherUnitTestFramework,IsDeleted,CreatedBy,CreatedOn)        
 --SELECT aa.ApplicationId,aa.UnitTestFrameworkID,aa.OtherUnitTestFramework,0,'System',GETDATE() FROM #tempUnitTestingData aa        
 END        
        
   drop table #app         
        
 ---------------        
        
  ---------------New Add 7-------------        
        
        
 --DELETE FROM  [PP].[AppInventoryRCMAttributes] WHERE ApplicationId in (SELECT ApplicationID FROM NewAppCogDetails)        
 --Insert into [PP].[AppInventoryRCMAttributes] (ApplicationID,NFRCaptured,IsUnitTestAutomated,TestingCoverage,IsRegressionTest,RegressionTestCoverage,IsDeleted,CreatedBy,CreatedOn)        
 -- SELECT ND.ApplicationID,b.NFRCaptured,        
 --  CASE         
 --   WHEN LOWER( b.IsUnitTestAutomated) ='yes'  THEN 1        
 --   WHEN  LOWER(b.IsUnitTestAutomated) ='no'  THEN 0 END,        
 --  b.TestingCoverage,        
 --  CASE         
 --   WHEN LOWER( b.IsRegressionTest) ='yes'  THEN 1        
 --   WHEN  LOWER(b.IsRegressionTest) ='no'  THEN 0 end,        
 --  b.RegressionTestCoverage,0, 'System',GETDATE()        
 --  FROM NewAppCogDetails ND         
 --  JOIN  [ADM].[AppInventoryUnitTestingCognizant_Upload] b on ND.ApplicationName=b.ApplicationName        
 --  WHERE b.CustomerId=@CustomerId        
        
        
 -----------------        
        
 DROP TABLE #Temp        
 DROP table #existingAppDetails        
 Drop TABLE #newAppDetails        
 DROP TABLE #NewAppCogDetails        
        
 COMMIT TRAN        
END TRY          
BEGIN CATCH          
        
  DECLARE @ErrorMessage VARCHAR(MAX);        
        
  SELECT @ErrorMessage = ERROR_MESSAGE()        
  ROLLBACK TRAN        
  --INSERT Error            
  EXEC AVL_InsertError '[dbo].[AddAppInventoryDetailsCognizant_PP] ', @ErrorMessage, 0,@CustomerId        
          
 END CATCH          
        
END
