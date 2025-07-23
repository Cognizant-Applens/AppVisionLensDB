/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [RLE].[GetAllMasterHierarchy_All]
As	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	  
 SELECT DISTINCT m.MarketID, m.MarketName, mu.MarketUnitID, mu.MarketUnitName,       
   bu.BusinessUnitID, bu.BusinessUnitName,       
   sbu1.SBU1ID, sbu1.SBU1Name, sbu2.SBU2ID, sbu2.SBU2Name,      
   v.VerticalID, v.VerticalName,sv.SubVerticalID, sv.SubVerticalName,      
   pcu.ParentCustomerID, pcu.ParentCustomerName, cu.CustomerID, cu.CustomerName,      
   cu.ESA_AccountId ESACustomerID,pc.PracticeID,pc.PracticeName,      
   p.ProjectID, p.ProjectName, p.ESAProjectID, ins.IndustrySegmentId, ins.IndustrySegmentName,
   cu.IsDeleted as CustomerIsDeleted,pcu.IsDeleted as ParentCustomerIsDeleted,p.IsDeleted as ProjectIsDeleted,
   case when (p.IsDeleted = 1 or pcu.IsDeleted = 1 or cu.IsDeleted = 1 ) then 1 else 0 end as IsDeletedflag,
   p.IsDebtEnabled, p.IsCoginzant, p.IsESAProject,
   DATEADD(MINUTE, 30, DATEADD(HOUR, 5, p.ProjectStartDate)) AS ProjectStartDate,
   DATEADD(MINUTE, 30, DATEADD(HOUR, 5, p.ProjectEndDate)) AS ProjectEndDate,
   p.BillType, p.ProjectCategory,cu.iscognizant
   --,OPL.Project_Owning_Unit as oplowningunit 
   INTO #Temp 
   FROM  MAS.Markets m (NOLOCK)     
   JOIN MAS.MarketUnits mu (NOLOCK) ON m.MarketID = mu.MarketID AND mu.IsDeleted = 0      
   JOIN MAS.BusinessUnits bu (NOLOCK) ON mu.MarketUnitID = bu.MarketUnitID AND bu.IsDeleted = 0      
   JOIN MAS.SubBusinessUnits1 sbu1 (NOLOCK) ON bu.BusinessUnitID = sbu1.BusinessUnitID AND sbu1.IsDeleted = 0      
   JOIN AVL.Customer cu (NOLOCK) ON cu.SBU1ID = sbu1.SBU1ID  --and cu.isdeleted = 0  
   JOIN MAS.Verticals v (NOLOCK) ON cu.VerticalID = v.VerticalID AND v.IsDeleted = 0      
   JOIN MAS.IndustrySegments ins (NOLOCK) ON ins.IndustrySegmentId = v.IndustrySegmentId AND ins.IsDeleted = 0      
   LEFT JOIN MAS.SubBusinessUnits2 sbu2 (NOLOCK) ON cu.SBU2ID = sbu2.SBU2ID AND sbu2.IsDeleted = 0                      
   LEFT JOIN MAS.ParentCustomers pcu (NOLOCK) ON cu.ParentCustomerID = pcu.ParentCustomerID    
   LEFT JOIN MAS.SubVerticals sv (NOLOCK) ON cu.SubVerticalID = sv.SubVerticalID AND sv.IsDeleted = 0      
   JOIN AVL.MAS_projectMaster p (NOLOCK) ON cu.CustomerID = p.CustomerID   --and p.isdeleted = 0
   LEFT JOIN MAS.ProjectPracticeMapping ppm (NOLOCK) ON p.ProjectID = ppm.ProjectID AND ppm.IsDeleted=0      
   LEFT JOIN MAS.Practices pc (NOLOCK) ON ppm.PracticeID = pc.PracticeID AND pc.IsDeleted = 0    
  -- LEFT JOIN [dbo].[OPLMasterdata] OPL (NOLOCK) ON OPL.ESA_PROJECT_ID = P.ESAPROJECTID AND OPL.ISDELETED = 0
   WHERE M.IsDeleted = 0 

  
   select Distinct AssociateID, ESA_AccountID, PrimaryPortfolioName INTO #PDL1
   from (select Distinct AssociateID, PortfolioQualifier1Id as ESA_AccountID,
   PrimaryPortfolioName,ROW_NUMBER() over 
   (partition by PortfolioQualifier1Id, PrimaryPortfolioName order by AssociateID) 
   as rownum from RLE.RHMSRoleDetails where RoleId ='R_ID_0390'
   and ActiveFlag = 1 and PortfolioQualifier1Type = 'Account') A where rownum =1

   SELECT P1.*,EA.AssociateName as PDLName 
   INTO #PDL
   FROM #PDL1 P1
   LEFT JOIN ESA.Associates(NOLOCK) EA
   ON EA.AssociateID  = P1.AssociateId


   select Distinct AssociateID, ESA_AccountID,PrimaryPortfolioName  INTO #ED1 
   from 
   (select  Distinct AssociateID, PortfolioQualifier1Id as ESA_AccountID,PrimaryPortfolioName,
   ROW_NUMBER() over (partition by PortfolioQualifier1Id,PrimaryPortfolioName order by AssociateID) 
   as rownum from RLE.RHMSRoleDetails where RoleId in('R_ID_0392') 
   and ActiveFlag = 1 and PrimaryPortfolioType = 'Horizontal') A where rownum = 1

    SELECT E1.*,EA.AssociateName as EDLName 
   INTO #EDL
   FROM #ED1 E1
   LEFT JOIN ESA.Associates(NOLOCK) EA
   ON EA.AssociateID  = E1.AssociateId

   SELECT A.AccessLevelID as ESAProjectId,'Applens Onboarding' AS IsApplensExempt,A.RequesterComments,
   CASE WHEN B.ID IS NULL THEN 1 ELSE B.ID END AS ReasonID,CASE WHEN B.ID IS NULL THEN 'Others'
   ELSE Reason END AS Reason
  INTO #Exemptions
   FROM [$(SmartGovernanceDB)].[dbo].ApplensExemptionDetails(NOLOCK) A
   LEFT JOIN [$(SmartGovernanceDB)].[dbo].ExemptionActivityLog(NOLOCK) EA ON A.AccessLevelID = EA.AccessLevelID AND EA.ID = (SELECT MAX(ID)
   FROM [$(SmartGovernanceDB)].[dbo].[ExemptionActivityLog](NOLOCK) WHERE AccessLevelID = A.AccessLevelID AND IsDeleted = 0 
   AND EA.OptedFor = 'Exemption' AND Status = 'Approved' AND ModuleID = 1)
   LEFT JOIN [$(SmartGovernanceDB)].[MAS].[ExemptionReason](NOLOCK) B ON B.ID = 
   CASE WHEN A.ReasonID IS NULL OR A.ReasonID = 0 THEN EA.ReasonID ELSE A.ReasonID END
   AND B.ModuleID = 1 WHERE A.IsDeleted = 0 AND CurrentlyExempted = 1 AND A.OptedFor = 'Exemption'

  --drop table #techdata
   SELECT DISTINCT ESA_PROJECT_ID,Count(Technology) as techcount
   into #techdata
   FROM DBO.OPLMASTERDATA(NOLOCK)
   where Technology is not null and isdeleted = 0
   group by ESA_PROJECT_ID
   having Count(Technology)>1

    SELECT DISTINCT ESA_PROJECT_ID,Count(Technology) as techcount
   into #techdata1
   FROM DBO.OPLMASTERDATA(NOLOCK)
   where Technology is not null and isdeleted = 0
   group by ESA_PROJECT_ID
   having Count(Technology) <= 1

   SELECT ESA_PROJECT_ID,AVL.Technology([ESA_Project_ID]) AS Technology 
   INTO #2tech
   FROM #techdata

   select distinct o.ESA_PROJECT_ID ,o.Technology  
   INTO #1tech
   FROM DBO.OPLMASTERDATA(NOLOCK) o
   join #techdata1 t1
   on o.ESA_PROJECT_ID = t1.ESA_PROJECT_ID
   where Technology is not null and isdeleted = 0

   
select A.ProjectID,  AVL.PPArcheType(ProjectID) AS AttributeValueName 
into #Archetype
from pp.scopeofwork(NOLOCK) A
join mas.PPAttributevalues(NOLOCK) B on A.ProjectTypeID = B.AttributeValueID
Where A.IsDeleted = 0 and B.IsDeleted = 0 and B.AttributeID = 4 AND isnull(AttributeValueName,'') <> ''


   SELECT DISTINCT T.*,
 -- C.IsCognizant, 
  GM.GeoMapID,
   CASE WHEN  GM.[SBU_Delivery] = 'CE' THEN 'CONTINENTAL EUROPE'
        WHEN GM.[SBU_Delivery] = 'HC-NA' THEN 'HEALTH NA'
		WHEN GM.[SBU_Delivery] = 'INS-NA' then 'Insurance-NA'
		WHEN GM.[SBU_Delivery] = 'LS-NA' then 'Life Sciences-NA'
		ELSE GM.[SBU_Delivery] END AS GeoMapping,
    OPL.[Final_Scope], OPL.[Tracking Mode], 
	DATEADD(MINUTE, 30, DATEADD(HOUR, 5, OPL.[Project_Ported_Date])) AS Project_Ported_Date,
   --OPL.[Project_Ported_Date],
   OPL.[Is Performance data Sharing restricted as per contract],
  AVL.ProjectScope(t.ProjectId) as ProjectScope,
  --AVL.Technology(OPL.[ESA_Project_ID]) AS Technology
  cast('' as nvarchar(max)) as Technology,EA.AssociateID AS PDLId,
   EA.PDLName as PDLName, EDL.AssociateID AS EDLId,EDL.EDLName as EDLName
   ,E.IsApplensExempt, CP.ScreenId, 
   GSM.[ProjectType] as [Project_Type],
   OPL.[Project_Owning_Unit] AS PracticeOwner,
   CASE WHEN OPL.[Project_Owning_Unit] IS NULL
   THEN 'Project Owning Unit Not Available' ELSE OPL.[Project_Owning_Unit] END AS [Project Owning Unit],
   CASE WHEN GM.[SBU_Delivery] IS NULL  THEN 'PC2Geo Mapping Not Applicable'
   else GM.[SBU_Delivery] END AS PC2GeoMapping,
   CASE WHEN isnull(E.IsApplensExempt,'') <> '' then 'Exempted'    WHEN  isnull(CP.ScreenID,0) <> 0 then 'Onboarded' else null END AS ProjectStatus
   ,ATY.AttributeValueName AS PPArcheType
   into #finaltemp
   FROM #Temp T
   JOIN AVL.Customer(NOLOCK) C
   ON C.ESA_AccountID = T.ESACustomerID 
   LEFT JOIN dbo.GeoMapping(NOLOCK) GM
   ON GM.ESA_AccountID = C.ESA_AccountID
   LEFT JOIN dbo.OPLMasterdata(NOLOCK) OPL
   ON OPL.ESA_Project_ID = T.EsaProjectID AND OPL.IsDeleted = 0
   LEFT JOIN #PDL(NOLOCK) EA
   ON EA.ESA_AccountId = T.ESACustomerID AND  EA.PrimaryPortfolioName = OPL.Project_Owning_Unit
   LEFT JOIN #EDL(NOLOCK) EDL
   ON EDL.ESA_AccountId = T.ESACustomerID AND  EDL.PrimaryPortfolioName = OPL.Project_Owning_Unit
   LEFT JOIN #Exemptions(NOLOCK) E
   ON E.EsaProjectID = T.EsaProjectID
   LEFT JOIN AVL.PRJ_ConfigurationProgress(NOLOCK) CP
   ON CP.ProjectID = T.ProjectId AND CP.IsDeleted = 0 AND CP.ScreenId = 4 AND CP.CompletionPercentage = 100
   LEFT JOIN ESA.projects(NOLOCK) GSM
   ON GSM.ID = T.ESAProjectId
   LEFT JOIN #Archetype (NOLOCK) ATY 
   ON ATY.ProjectId = T.ProjectId

   UPDATE f SET f.Technology = t1.Technology
   FROM  #finaltemp f
   JOIN #1tech t1
   ON t1.ESA_Project_ID = f.ESAProjectID

   UPDATE f SET f.Technology = t1.Technology
   FROM  #finaltemp f
   JOIN #2tech t1
   ON t1.ESA_Project_ID = f.ESAProjectID



     SELECT * , CASE WHEN (ISNULL(projectscope,'') LIKE '%Development%' AND ISNULL(projectscope,'') NOT LIKE '%Maintenance%') THEN 'AD'
                   WHEN (ISNULL(projectscope,'') LIKE '%Development%' AND ISNULL(projectscope,'') LIKE '%Maintenance%') THEN 'ADM'  
                   WHEN (ISNULL(projectscope,'') LIKE '%Maintenance%' AND ISNULL(projectscope,'') NOT LIKE '%Development%') THEN 'AMS'
                   WHEN (ISNULL(projectscope,'') LIKE '%CIS%' AND ISNULL(projectscope,'') NOT LIKE '%Maintenance%' AND projectscope NOT LIKE '%Development%') THEN 'CIS'
                   WHEN (ISNULL(PPArchetype,'') LIKE '%Development%' or ISNULL(PPArchetype,'')  LIKE '%Modernization%') THEN 'AD'
				   WHEN (ISNULL(PPArchetype,'') LIKE '%Enhancement and Support%') THEN 'AMS'
				   WHEN (ISNULL(PPArchetype,'') <> '') THEN 'Others'
				   WHEN (ISNULL(projectscope,'') = '' AND ISNULL(PPArchetype,'') <> '') THEN 'Others'
				   ELSE 'NA' END AS [Project Type]
   FROM #finaltemp --where isnull(projectscope,'') <> '' --where esaprojectid in( '1000004197','1000004870','1000004997')
   --where esaprojectid in( '1000004197','1000004870','1000004997')

END


