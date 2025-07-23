CREATE PROCEDURE [dbo].[InsertAdoptionProjectDetails] (          
@TVP_ParentData TVP_AdoptionParentProjectDetails READONLY,          
@TVP_ChildData TVP_AdoptionChildProjectDetails READONLY,  
@TVP_AllData TVP_AdoptionADMProjectDetails READONLY)  
           
AS          
BEGIN          
BEGIN TRY    
  
 --TRUNCATE TABLE [dbo].[AdoptionParentProjectDetails]          
 --TRUNCATE TABLE [dbo].[AdoptionChildProjectDetails]          
          
 --INSERT INTO [dbo].[AdoptionParentProjectDetails]         
 --SELECT ESAProjectID,          
 --AccountId,          
 --ParentAccountID,          
 --Market,          
 --FinalScope,          
 --IsPerformanceSharingRestricted    
 --INTO AdoptionParentProjectDetails    
 --FROM @TVP_ParentData    
     
 SELECT ESAProjectID,          
 AccountId,          
 ParentAccountID,          
 Market,          
 FinalScope,          
 IsPerformanceSharingRestricted  
 INTO #AdoptionParentProjectDetails    
 FROM @TVP_ParentData       
     
 --SELECT ESAProjectID,          
 --ParentESAProjectID        
 --INTO AdoptionChildProjectDetails    
 --FROM @TVP_ChildData     
          
 --INSERT INTO [dbo].[AdoptionChildProjectDetails]      
   
 SELECT ESAProjectID,          
 ParentESAProjectID  
 INTO #AdoptionChildProjectDetails    
 FROM @TVP_ChildData     
   
 SELECT [ESAProjectID],[ESAProjectName],[Project Start Date],[Project End Date],[AccountId],[AccountName],[ParentAccountID],[ParentAccountName],  
 [ProjectOwningUnit],[TotalFTE],[Vertical],[Market],[MarketUnit],[BU],[SBU1Id],[SBU1],[SBU2Id],[SBU2],[ESA Project Type],[ESA Project Category],[3x3 Matrix],[Archetype],[ArchetypeCluster],  
 [WorkCategory],[PracticeArea],[IndustrySegment],[FinalScope],[Dex Assessment Feasibility Flag],[IsPerformanceSharingRestricted],  
 [FirstInscopeDate],[ESAProjectCountry],[ESA_PM_Id],[ESA_PM_Name],[ProjectOwnerId],[ProjectOwnerName],[ProjectOwner_ESA_PM_Department],  
 [EngagementDeliveryLead],[PortfolioDeliveryLead],[DeliveryExcellencePOC],[Client_Practice]  
 INTO #AdoptionAllProjectDetails  
 FROM @TVP_AllData  
  
 --Insert Child Project with Parent Project's details  
 SELECT B.ESAProjectID,[ESAProjectName],[Project Start Date],[Project End Date],[AccountId],[AccountName],[ParentAccountID],[ParentAccountName],  
 [ProjectOwningUnit],[TotalFTE],[Vertical],[Market],[MarketUnit],[BU],[SBU1Id],[SBU1],[SBU2Id],[SBU2],[ESA Project Type],[ESA Project Category],[3x3 Matrix],[Archetype],[ArchetypeCluster],  
 [WorkCategory],[PracticeArea],[IndustrySegment],[FinalScope],[Dex Assessment Feasibility Flag],[IsPerformanceSharingRestricted],  
 [FirstInscopeDate],[ESAProjectCountry],[ESA_PM_Id],[ESA_PM_Name],[ProjectOwnerId],[ProjectOwnerName],[ProjectOwner_ESA_PM_Department],  
 [EngagementDeliveryLead],[PortfolioDeliveryLead],[DeliveryExcellencePOC],A.Client_Practice INTO #ChildData FROM #AdoptionAllProjectDetails A JOIN #AdoptionChildProjectDetails B ON A.EsaProjectId=B.ParentESAProjectID  
  
 INSERT INTO #AdoptionAllProjectDetails  
 SELECT [ESAProjectID],[ESAProjectName],[Project Start Date],[Project End Date],[AccountId],[AccountName],[ParentAccountID],[ParentAccountName],  
 [ProjectOwningUnit],[TotalFTE],[Vertical],[Market],[MarketUnit],[BU],[SBU1Id],[SBU1],[SBU2Id],[SBU2],[ESA Project Type],[ESA Project Category],[3x3 Matrix],[Archetype],[ArchetypeCluster],  
 [WorkCategory],[PracticeArea],[IndustrySegment],[FinalScope],[Dex Assessment Feasibility Flag],[IsPerformanceSharingRestricted],  
 [FirstInscopeDate],[ESAProjectCountry],[ESA_PM_Id],[ESA_PM_Name],[ProjectOwnerId],[ProjectOwnerName],[ProjectOwner_ESA_PM_Department],  
 [EngagementDeliveryLead],[PortfolioDeliveryLead],[DeliveryExcellencePOC],Client_Practice  
 FROM #ChildData  
  
 TRUNCATE TABLE dbo.ADM_OplMasterData   
  
 INSERT INTO dbo.ADM_OplMasterData ([ESAProjectID],[ESAProjectName],[Project Start Date],[Project End Date],[AccountId],[AccountName],[ParentAccountID],[ParentAccountName],  
 [ProjectOwningUnit],[TotalFTE],[Vertical],[Market],[MarketUnit],[BU],[SBU1Id],[SBU1],[SBU2Id],[SBU2],[ESA Project Type],[ESA Project Category],[3x3 Matrix],[Archetype],[ArchetypeCluster],  
 [WorkCategory],[PracticeArea],[IndustrySegment],[FinalScope],[Dex Assessment Feasibility Flag],[IsPerformanceSharingRestricted],  
 [FirstInscopeDate],[ESAProjectCountry],[ESA_PM_Id],[ESA_PM_Name],[ProjectOwnerId],[ProjectOwnerName],[ProjectOwner_ESA_PM_Department],  
 [EngagementDeliveryLead],[PortfolioDeliveryLead],[DeliveryExcellencePOC],Client_Practice,[CreatedBy],[CreatedDate])  
  
 SELECT [ESAProjectID],[ESAProjectName],[Project Start Date],[Project End Date],[AccountId],[AccountName],[ParentAccountID],[ParentAccountName],  
 [ProjectOwningUnit],[TotalFTE],[Vertical],[Market],[MarketUnit],[BU],[SBU1Id],[SBU1],[SBU2Id],[SBU2],[ESA Project Type],[ESA Project Category],[3x3 Matrix],[Archetype],[ArchetypeCluster],  
 [WorkCategory],[PracticeArea],[IndustrySegment],[FinalScope],[Dex Assessment Feasibility Flag],[IsPerformanceSharingRestricted],  
 [FirstInscopeDate],[ESAProjectCountry],[ESA_PM_Id],[ESA_PM_Name],[ProjectOwnerId],[ProjectOwnerName],[ProjectOwner_ESA_PM_Department],  
 [EngagementDeliveryLead],[PortfolioDeliveryLead],[DeliveryExcellencePOC],Client_Practice,'System',GETDATE() FROM #AdoptionAllProjectDetails  
     
  UPDATE A SET A.Archetype=B.Archetype, A.WorkCategory=B.WorkCategory, A.CreatedBy='436569' FROM dbo.ADM_OPLMasterData A JOIN [dbo].[OPLDQReport] B 
 ON A.EsaProjectId=B.EsaProjectId

 -- UPDATE A SET A.Archetype=B.Archetype, A.WorkCategory=B.WorkCategory, A.CreatedBy='436569' FROM dbo.ADM_OPLMasterData A JOIN [dbo].[OPLDQReport_AIA] B 
 --ON A.EsaProjectId=B.EsaProjectId

  UPDATE A SET A.Archetype=B.Archetype, A.WorkCategory=B.WorkCategory, A.CreatedBy='436569' FROM dbo.ADM_OPLMasterData A JOIN [dbo].[OPLDQReport_IOT] B 
 ON A.EsaProjectId=B.EsaProjectId

 -- UPDATE A SET A.Archetype=B.Archetype, A.WorkCategory=B.WorkCategory, A.CreatedBy='436569' FROM dbo.ADM_OPLMasterData A JOIN [dbo].[OPLDQReport_EPS] B 
 --ON A.EsaProjectId=B.EsaProjectId
  
  if exists (SELECT 1 FROM dbo.DQR_Data_History WHERE ID = 2 and MONTH(enddate) = MONTH(Getdate()))

begin

  drop table dbo.DQR_oplmasterdata

  select * into  dbo.DQR_oplmasterdata  from dbo.[ADM_OplMasterData] with (nolock)

  UPDATE dbo.DQR_Data_History
    SET 
        EndDate = NULL,
        Modifieddate = Getdate() where id='2'
end
      --delete from dbo.[ADM_OplMasterData]
      
 --SELECT * FROM  [dbo].[AdoptionParentProjectDetails](NOLOCK)          
 --SELECT * FROM  [dbo].[AdoptionChildProjectDetails](NOLOCK)          
           
 SELECT DISTINCT PM.ProjectID,PM.EsaProjectID, PM.ProjectName           
 INTO #Onboarding          
    FROM  AVL.MAS_ProjectMaster PM WITH (NOLOCK)          
    INNER JOIN AVL.PRJ_ConfigurationProgress CP1 WITH (NOLOCK)           
  ON CP1.ProjectID = PM.ProjectID AND CP1.ScreenID = 4 AND CP1.CompletionPercentage = 100  AND CP1.IsDeleted = 0           
    WHERE PM.IsDeleted = 0            
          
 SELECT DISTINCT PM.ProjectID,PM.EsaProjectID,PM.ProjectName,'Ticketingmodule' as ExemptionFor           
 INTO #Exemption          
 FROM [$(SmartGovernanceDB)].[dbo].[ApplensExemptionDetails](NOLOCK) ED           
 LEFT JOIN [$(SmartGovernanceDB)]. [MAS].[ExemptionReason](NOLOCK) ER          
  ON ED.ReasonID = ER.ID          
 LEFT JOIN [$(SmartGovernanceDB)].[dbo].ModuleExemptionDetails(NOLOCK) ME           
  ON ME.ApplensExemptionID = ED.ID          
 INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM           
  ON ED.AccessLevelID = PM.EsaProjectID          
 WHERE (ED.OptedFor='Exemption' AND ED.Status='Approved' AND ED.IsDeleted='0')           
 OR (ME.ModuleId=4 AND ME.OptedFor='Exemption' AND ME.Status='Approved' AND ME.IsDeleted=0)        
    
 DELETE FROM #exemption where esaprojectid in (1000197714,1000241319,1000023190,1000226454,1000233322,1000194794,1000280452,1000255522,1000279836)    
 DELETE FROM #Onboarding WHERE ProjectID IN (SELECT ProjectID FROM #Exemption)      
 DELETE FROM #Onboarding where EsaProjectID not like ('%1000%')    
    
 SELECT DISTINCT PM.projectid, EsaProjectID , ProjectName           
 INTO #AD          
 FROM ADM.TM_TRN_WorkItemTimesheetDetail (NOLOCK)  wtd           
 JOIN [ADM].[ALM_TRN_WorkItem_Details] wd (NOLOCK)           
  ON wtd.WorkItemDetailsId = wd.workitemdetailsid           
 JOIN AVL.MAS_ProjectMaster pm (NOLOCK)           
  ON pm.ProjectID = wd.Project_Id           
 JOIN AVL.Customer c (NOLOCK)           
  ON c.CustomerID = pm.CustomerID          
 JOIN AVL.PRJ_ConfigurationProgress CP (NOLOCK)           
  ON CP.ProjectID = PM.ProjectID           
 AND CP.ScreenID = 4 AND CP.CompletionPercentage = 100  AND CP.IsDeleted = 0           
 WHERE BUID<> 10  and ESAPROJECTID NOT IN (1000234764,1000248336)          
 GROUP BY PM.projectid, EsaProjectID, ProjectName          
 HAVING MIN(wtd.CreatedDate) <= DateAdd( day, -28, GetDate())          
          
 DELETE FROM #AD where ProjectID IN          
 (SELECT ProjectID from  #AD WHERE ProjectID IN( SELECT ProjectID FROM #Exemption))          
          
 CREATE TABLE #ProjectDetails (          
 ESAProjectID NVARCHAR(50) NOT NULL,          
 AccountId NVARCHAR(50)  NULL,          
 ParentAccountID NVARCHAR(50) NULL,          
 Market NVARCHAR(50)  NULL,          
 FinalScope NVARCHAR(50)  NULL,          
 IsPerformanceSharingRestricted BIT  NULL,          
 BU NVARCHAR(100) NULL,          
 IsChildProject BIT NOT NULL,          
 IsExempted BIT NULL,          
 Applensscope NVARCHAR(50) NULL,  
 Client_Practice NVARCHAR(50) NULL  
 )          
          
 INSERT INTO #ProjectDetails (ESAProjectID,AccountID,ParentAccountID,Market,FinalScope,IsPerformanceSharingRestricted,BU,IsChildProject,IsExempted,Applensscope)          
 SELECT DISTINCT  ESAProjectID,AccountID,ParentAccountID,Market,FinalScope,IsPerformanceSharingRestricted,NULL,0,          
 NULL,NULL      
 FROM #AdoptionParentProjectDetails        
           
 INSERT INTO #ProjectDetails (ESAProjectID,AccountID,ParentAccountID,Market,FinalScope,IsPerformanceSharingRestricted,BU,IsChildProject,IsExempted,Applensscope)          
 SELECT DISTINCT  ESAProjectID,NULL,ParentESAProjectId,NULL,NULL,NULL,NULL,1,          
 NULL,NULL       
 FROM #AdoptionChildProjectDetails         
          
      
 UPDATE PD SET PD.IsExempted = 1          
 FROM #ProjectDetails PD          
 JOIN #Exemption(NOLOCK) EM          
 ON EM.ESAProjectId = PD.ESAPRojectID          
          
 UPDATE PD SET PD.IsExempted = 0       
 FROM #ProjectDetails PD          
 JOIN #AD(NOLOCK) AD          
 ON AD.ESAProjectId = PD.ESAPRojectID          
          
 UPDATE PD SET PD.IsExempted = 0          
 FROM #ProjectDetails PD          
 JOIN #Onboarding(NOLOCK) AD          
 ON AD.ESAProjectId = PD.ESAPRojectID         
     
     
           
 SELECT DISTINCT CP.ESAprojectId,PP.AccountId, PP.Market,PP.FinalScope,PP.IsPerformanceSharingRestricted        
 INTO #ChildTemp          
 FROM #AdoptionChildProjectDetails(NOLOCK)  CP          
 JOIN #AdoptionParentProjectDetails(NOLOCK)  PP           
 ON PP.ESAProjectId = CP.ParentESAProjectId          
          
 UPDATE PD SET           
 PD.AccountId = CT.AccountId, PD.Market = CT.Market, PD.FinalScope = CT.FinalScope,          
 PD.IsPerformanceSharingRestricted = CT.IsPerformanceSharingRestricted          
 FROM #ProjectDetails PD          
 JOIN #ChildTemp(NOLOCK) CT          
 ON  CT.ESAProjectId= PD.ESAProjectId          
 WHERE PD.IsChildProject = 1          
          
 UPDATE PD SET PD.BU = GM.SBU_Delivery          
 FROM #ProjectDetails PD          
 JOIN DBO.GeoMapping(NOLOCK) GM          
 ON GM.ESA_AccountId = PD.AccountId      
 WHERE GM.IsDeleted=0    
          
 SELECT ESAProjectId, IsExempted            
 INTO #ParentExempted          
 FROM #ProjectDetails where IsChildProject = 0          
          
 UPDATE PD SET PD.IsExempted = PE.IsExempted          
 FROM #ProjectDetails PD          
 JOIN #ParentExempted PE          
 ON PE.ESAProjectId = PD.ParentAccountId          
 WHERE PD.IsChildProject = 1          
                 
 UPDATE PD          
 SET PD.ApplensScope =           
 CASE WHEN (PD.FinalScope = 'In scope' AND PD.IsPerformanceSharingRestricted = 1)           
 THEN 'Not In Scope'          
 WHEN (PD.FinalScope = 'In scope' AND  (PD.IsExempted = 1))    
 THEN 'Not In Scope'          
 ELSE PD.FinalScope          
 END          
 FROM #ProjectDetails PD          
          
             
            
DECLARE @StoreProjectlistSP TABLE(          
ESAProjectId NVARCHAR(50),          
WorkProfilerMandated  NVARCHAR(100))    
    INSERT INTO @StoreProjectlistSP EXEC dbo.GetOnboardingProjectDetails       
    select * INTO #TEMP from @StoreProjectlistSP     
    
    
    
SELECT DISTINCT  PD.ESAProjectID INTO #notinscopeProjects    
FROM #ProjectDetails PD     
EXCEPT     
SELECT DISTINCT ESAProjectID from #TEMP    
    
UPDATE PD    
SET PD.Applensscope='Not In scope' FROM #ProjectDetails PD     
JOIN #notinscopeProjects NP ON NP.ESAProjectId=PD.ESAProjectID     
    
  --Select ESAProjectID,Applensscope as ApplensScope,ISNULL(BU,'') as BU,Market as MARKET,IsChildProject from #ProjectDetails     
  --where Applensscope='In scope'    
      
  Select ESAProjectID,ParentAccountId,Applensscope as ApplensScope,ISNULL(BU,'') as BU,    
  Market as MARKET,IsChildProject   
  Into #FinalProjectDetails    
  from #ProjectDetails     
  where Applensscope='In scope'    
      
  SELECT ESAProjectID,ParentAccountId,Applensscope as ApplensScope,ISNULL(BU,'') as BU,    
  Market as MARKET,IsChildProject  
  INTO #PProjectDetails    
  FROM #FinalProjectDetails    
  WHERE IsChildProject = 0    
    
  SELECT F.ESAProjectID,F.ParentAccountId,F.Applensscope as ApplensScope,ISNULL(F.BU,'') as BU,    
  F.Market as MARKET,F.IsChildProject    
  INTO #CProjectDetails    
  FROM #FinalProjectDetails F    
  JOIN #PProjectDetails P ON F.ParentAccountId = P.ESAProjectID    
  WHERE F.IsChildProject = 1    
    
  Select ESAProjectID,Applensscope as ApplensScope,ISNULL(BU,'') as BU,    
  Market as MARKET,IsChildProject from #PProjectDetails     
  UNION    
  Select ESAProjectID,Applensscope as ApplensScope,ISNULL(BU,'') as BU,    
  Market as MARKET,IsChildProject from #CProjectDetails     
         
END TRY      
  BEGIN CATCH      
  DECLARE @ErrorMessage VARCHAR(8000);      
  SELECT @ErrorMessage = ERROR_MESSAGE()      
  --INSERT Error          
  EXEC [dbo].AVL_InsertError '[dbo].[InsertAdoptionProjectDetails] ', @ErrorMessage, '',''      
  RETURN @ErrorMessage      
  END CATCH         
      
END  