
CREATE PROCEDURE [PP].[GetAllTileProgressPercentage]
AS
BEGIN
SET NOCOUNT ON


-- ************************** PROJECT PROFILING TILE PROGRESS **************************

-- Fetch the Active Project details
SELECT PM.CustomerID, PM.EsaProjectID,PM.ProjectID, PM.ProjectName, ISNULL(PC.SupportTypeId, 0) AS SupportTypeId
INTO #ProjectDetails
FROM --pp.ProjectDetails PD JOIN 
avl.MAS_ProjectMaster PM
join pp.ProjectProfilingTileProgress PT on PM.ProjectID=PT.ProjectID and PT.IsDeleted='0'
	--ON PM.ProjectID = PD.ProjectID-- AND PM.IsDeleted = 0
LEFT JOIN AVL.MAP_ProjectConfig PC 
	ON PC.ProjectID = PM.ProjectID 

-- App Inventory Completion Percentage
SELECT DISTINCT PD.ProjectID, 
	CASE WHEN APM.ProjectID IS NOT NULL AND CompletionPercentage < 100 THEN CompletionPercentage + 25
		 WHEN APM.ProjectID IS NULL AND CompletionPercentage = 100 THEN 75
		 ELSE CompletionPercentage END AS AppInventoryCompPerc
INTO #AppInventoryCompPerc
FROM #ProjectDetails PD
JOIN avl.prj_configurationprogress CP 
	ON CP.CustomerID = PD.CustomerID AND ScreenID = 1 AND CP.IsDeleted = 0
LEFT JOIN AVL.APP_MAP_ApplicationProjectMapping APM
	ON APM.ProjectID = PD.ProjectID AND APM.IsDeleted = 0	

-- Infra Inventory Completion Percentage
SELECT DISTINCT PD.ProjectID, 
	CASE WHEN TPM.ProjectID IS NOT NULL AND CompletionPercentage < 100 THEN CompletionPercentage + 25
		  WHEN TPM.ProjectID IS NULL AND CompletionPercentage = 100 THEN 75
		 ELSE CompletionPercentage END AS InfraInventoryCompPerc
INTO #InfraInventoryCompPerc
FROM #ProjectDetails PD
JOIN avl.prj_configurationprogress CP 
	ON CP.CustomerID = PD.CustomerID AND ScreenID = 17 AND CP.IsDeleted = 0
LEFT JOIN AVL.InfraTowerProjectMapping TPM
	ON TPM.ProjectID = PD.ProjectID AND TPM.IsDeleted = 0	

-- User Management Completion Percentage
SELECT ProjectID, CASE WHEN COUNT(UserRoleMappingID) > 0 THEN 100 ELSE 0 END AS UserMgmtCompPerc
INTO #UserDetailsCompPerc
FROM AVL.UserRoleMapping (NOLOCK) URM
JOIN #ProjectDetails PD
	ON PD.ProjectID = URM.AccessLevelID AND URM.RoleID != 1 AND URM.IsActive = 1 AND URM.AccessLevelSourceID = 4
GROUP BY ProjectID

-- Adaptors Completion Percentage
SELECT DISTINCT PD.ProjectID, PAV.AttributeValueID AS 'AttributeValueID', ppav.AttributeValueName AS 'AttributeValueName'  
INTO #ScopeDetails  
FROM #ProjectDetails PD
JOIN PP.ProjectAttributeValues PAV ON PAV.ProjectID = PD.ProjectID AND PAV.AttributeID = 1 AND PAV.IsDeleted = 0  
JOIN MAS.PPAttributeValues ppav ON PAV.AttributeValueID = ppav.AttributeValueID    
	AND pav.AttributeID = ppav.AttributeID AND ppav.IsDeleted = 0 AND ppav.AttributeID = 1  

SELECT DISTINCT PD.ProjectID, ISNULL(IsApplensAsALM, 0) AS IsApplensAsALM, 
    CASE WHEN SDALM.ProjectID IS NOT NULL THEN 1 ELSE 0 END AS IsALM,
	CASE WHEN SDITSM.ProjectID IS NOT NULL THEN 1 ELSE 0 END AS IsITSM
INTO #AdaptorConfig
FROM #ProjectDetails PD 
JOIN PP.ScopeOfWork SCOPE 
	ON SCOPE.ProjectID = PD.ProjectID
LEFT JOIN #ScopeDetails SDALM 
	ON SDALM.ProjectID = PD.ProjectID AND SDALM.AttributeValueID IN (1,4) -- ALM
LEFT JOIN #ScopeDetails SDITSM 
	ON SDITSM.ProjectID = PD.ProjectID AND SDITSM.AttributeValueID IN (2,3) -- ITSM

-- ALM Completion Percentage
SELECT DISTINCT AC.ProjectID, 
	(CASE WHEN CN.ProjectId IS NOT NULL THEN 20 ELSE 0 END) + 
	(CASE WHEN WT.ProjectId IS NOT NULL THEN 20 ELSE 0 END) + 
	(CASE WHEN P.ProjectId IS NOT NULL THEN 20 ELSE 0 END) + 
	(CASE WHEN SV.ProjectId IS NOT NULL THEN 20 ELSE 0 END) + 
	(CASE WHEN S.ProjectId IS NOT NULL THEN 20 ELSE 0 END) AS ALMConfigCompPerc
INTO #ALMConfigCompPerc
FROM #AdaptorConfig AC
LEFT JOIN PP.ALM_MAP_ColumnName CN ON CN.ProjectId = AC.ProjectID AND CN.IsDeleted = 0
LEFT JOIN PP.ALM_MAP_WorkType WT ON WT.ProjectId = AC.ProjectID AND WT.IsDeleted = 0
LEFT JOIN PP.ALM_MAP_Priority P ON P.ProjectId = AC.ProjectID AND P.IsDeleted = 0
LEFT JOIN PP.ALM_MAP_Severity SV ON SV.ProjectId = AC.ProjectID AND SV.IsDeleted = 0
LEFT JOIN PP.ALM_MAP_Status S ON S.ProjectId = AC.ProjectID AND S.IsDeleted = 0
WHERE AC.IsALM = 1

-- ITSM Completion Percentage
SELECT DISTINCT AC.ProjectID, CONVERT(INT, ( CONVERT(DECIMAL(18, 2), SUM(CompletionPercentage))    
                / 1200 ) * 100) AS ITSMConfigCompPerc
INTO #ITSMConfigCompPerc
FROM #AdaptorConfig AC
JOIN avl.prj_configurationprogress CP ON CP.ProjectID = AC.ProjectID AND CP.ScreenID = 2 AND CP.IsDeleted = 0
WHERE AC.IsITSM = 1
GROUP BY AC.ProjectID

-- Project Profiling Tiles Completion Percentage
SELECT distinct PD.EsaProjectID, PD.ProjectName, T1PRO.TileProgressPercentage AS ProjectDetailCompPerc,
    CASE WHEN SupportTypeId = 1 OR SupportTypeId = 4 THEN ISNULL(T2PRO_App.AppInventoryCompPerc, 0)
									 WHEN SupportTypeId = 2 THEN ISNULL(T2PRO_Infra.InfraInventoryCompPerc, 0)
									 WHEN SupportTypeId = 3 THEN (ISNULL(T2PRO_App.AppInventoryCompPerc, 0) + ISNULL(T2PRO_Infra.InfraInventoryCompPerc, 0)) / 2
								END AS AppInventoryCompPerc,
	T3PRO.UserMgmtCompPerc, T4PRO.TileProgressPercentage AS ServiceCatalogCompPerc,
	CASE WHEN AC.IsApplensAsALM = 0 
	THEN 
		CASE WHEN AC.IsALM = 1 AND AC.IsITSM = 1 THEN (ISNULL(T5PRO_ALM.ALMConfigCompPerc, 0) + ISNULL(T5PRO_ITSM.ITSMConfigCompPerc, 0)) / 2
			 WHEN AC.IsALM = 1 AND AC.IsITSM = 0 THEN ISNULL(T5PRO_ALM.ALMConfigCompPerc, 0)
			 WHEN AC.IsALM = 0 AND AC.IsITSM = 1 THEN ISNULL(T5PRO_ITSM.ITSMConfigCompPerc, 0)
			 ELSE 0 
	    END
	ELSE 100 END AS AdaptorCompPerc into #temp
FROM #ProjectDetails PD
LEFT JOIN pp.ProjectProfilingTileProgress T1PRO
	ON T1PRO.ProjectID = PD.ProjectID AND T1PRO.TileID = 1 AND T1PRO.IsDeleted = 0
LEFT JOIN #AppInventoryCompPerc T2PRO_App
	ON T2PRO_App.ProjectID = PD.ProjectID
LEFT JOIN #InfraInventoryCompPerc T2PRO_Infra
	ON T2PRO_Infra.ProjectID = PD.ProjectID
LEFT JOIN #UserDetailsCompPerc T3PRO
	ON T3PRO.ProjectID = PD.ProjectID
LEFT JOIN pp.ProjectProfilingTileProgress T4PRO
	ON T4PRO.ProjectID = PD.ProjectID AND T4PRO.TileID = 4 AND T4PRO.IsDeleted = 0
LEFT JOIN #AdaptorConfig AC
	ON AC.ProjectID = PD.ProjectID
LEFT JOIN #ALMConfigCompPerc T5PRO_ALM
	ON T5PRO_ALM.ProjectID = PD.ProjectID
LEFT JOIN #ITSMConfigCompPerc T5PRO_ITSM
	ON T5PRO_ITSM.ProjectID = PD.ProjectID

SELECT ProjectID,COUNT(ServiceMapID) as 'count' into #ServiceCount 
		 FROM AVL.TK_PRJ_ProjectServiceActivityMapping(NOLOCK) 
                                           WHERE ProjectID in (select ProjectID  from #temp A join AVL.MAS_ProjectMaster B on A.EsaProjectID=B.EsaProjectID
										   where A.ServiceCatalogCompPerc is null or A.ServiceCatalogCompPerc=0 )
                                           AND ISNULL(IsDeleted,0)=0 group by ProjectID having COUNT(ServiceMapID)>0
 
 update #temp set ServiceCatalogCompPerc='100' where EsaProjectID in
 (select EsaProjectID from #ServiceCount A join AVL.MAS_ProjectMaster B on A.projectid=B.projectid)

	select * from #temp  
	
DROP TABLE #AppInventoryCompPerc
DROP TABLE #InfraInventoryCompPerc
DROP TABLE #UserDetailsCompPerc
DROP TABLE #ScopeDetails
DROP TABLE #AdaptorConfig
DROP TABLE #ALMConfigCompPerc
DROP TABLE #ITSMConfigCompPerc
DROP TABLE #ProjectDetails



SET NOCOUNT OFF

END