CREATE PROCEDURE [dbo].[GetOnboardingProjectDetails]
AS
BEGIN
CREATE TABLE #ActiveProjectList(
ESAProjectId NVARCHAR(50),
WorkProfilerMandated  NVARCHAR(100))

-- Active Projects
INSERT INTO #ActiveProjectList
select DISTINCT ESAProjectId, 'NA' AS WorkProfilerMandated
from AVL.MAS_ProjectMaster(nolock) pm
join ESA.Projects(nolock) p on p.ID=pm.EsaProjectID
join avl.customer(nolock) c on c.customerid = pm.customerid
join dbo.vw_GMSPMO_Project(nolock) GP  on GP.Project_ID = PM.ESAProjectId
where pm.IsCoginzant = 1 and pm.isdeleted = 0
and c.isdeleted = 0 and c.iscognizant= 1 and gp.Project_End_Date >= GetDate()


SELECT A.AccessLevelID as AccessLevelID
,'Applens Onboarding' AS IsApplensExempt
,A.RequesterComments
,CASE 
WHEN B.ID IS NULL		THEN 1
		ELSE B.ID
		END AS ReasonID
	,CASE 
		WHEN B.ID IS NULL
			THEN 'Others'
		ELSE Reason
		END AS Reason
		Into #Exempted
FROM [$(SmartGovernanceDB)].[dbo].ApplensExemptionDetails A
LEFT JOIN [$(SmartGovernanceDB)].[dbo].ModuleExemptionDetails(NOLOCK) ME ON ME.ApplensExemptionID = A.ID
LEFT JOIN [$(SmartGovernanceDB)].[dbo].ExemptionActivityLog EA ON A.AccessLevelID = EA.AccessLevelID
	AND EA.ID = (
		SELECT MAX(ID)
		FROM [$(SmartGovernanceDB)].[dbo].[ExemptionActivityLog]
		WHERE AccessLevelID = A.AccessLevelID
			AND IsDeleted = 0
			AND OptedFor = 'Exemption' AND Status = 'Approved' AND (ModuleID = '1' OR ModuleID = '4')
		)
LEFT JOIN [$(SmartGovernanceDB)].[MAS].[ExemptionReason] B ON B.ID = (
		CASE 
			WHEN A.ReasonID IS NULL
				OR A.ReasonID = 0
				THEN EA.ReasonID
			ELSE A.ReasonID
			END
		)
	AND (B.ModuleID = '1' OR B.ModuleID = '4')
WHERE (A.OptedFor = 'Exemption'  AND A.Status = 'Approved' AND A.CurrentlyExempted = 1 AND A.IsDeleted = 0) 
OR (ME.ModuleID = 4 AND ME.OptedFor = 'Exemption' AND ME.Status = 'Approved' AND ME.CurrentlyExempted = 1 AND ME.IsDeleted = 0)



	select distinct ESAProjectId 
	into #onboarded
	from avl.prj_configurationProgress cp
	join AVL.Mas_ProjectMaster pm on pm.ProjectId = cp.ProjectId
	join avl.customer c on c.customerid = pm.customerid and c.isdeleted = 0
	where ScreenId = 4 and CompletionPercentage = 100 and cp.Isdeleted = 0 and pm.isdeleted = 0 and c.iscognizant = 1


		DELETE FROM #onboarded WHERE ESAProjectID IN (SELECT AccessLevelId FROM #Exempted)

  UPDATE APL SET APL.WorkProfilerMandated = 'Exempted'
  FROM #ActiveProjectList APL 
  JOIN #Exempted E on APL.ESAProjectId = E.AccessLevelID
  
    UPDATE APL SET APL.WorkProfilerMandated = 'Onboarded'
  FROM #ActiveProjectList APL 
  JOIN #Onboarded OB on APL.ESAProjectId = OB.EsaProjectId


select * from #ActiveProjectList where WorkProfilerMandated in ('Onboarded','Exempted')
  

END
