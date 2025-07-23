/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE VIEW [dbo].[VW_Project_Config_Status] AS
WITH CTE AS (

 select distinct EsaProjectID,ProjectName,A.ProjectID,A.CustomerID , ISNULL(D.SupportTypeId, 0) AS SupportTypeId
from AVL.MAS_ProjectMaster (Nolock) A
join PP.ProjectAttributeValues(Nolock) B on A.ProjectID=B.ProjectID
join MAS.PPAttributeValues C on B.AttributeValueID=C.AttributeValueID
left join  AVL.MAP_ProjectConfig D on A.ProjectID=D.ProjectID
where B.AttributeID='1' and A.IsDeleted='0' and B.IsDeleted='0' and C.IsDeleted='0' and EsaProjectID  like '%1000%'
),
APPCTE AS (
SELECT DISTINCT PD.ProjectID, 
	CASE WHEN APM.ProjectID IS NOT NULL AND CompletionPercentage < 100 THEN CompletionPercentage + 25
		 WHEN APM.ProjectID IS NULL AND CompletionPercentage = 100 THEN 75
		 ELSE CompletionPercentage END AS AppInventoryCompPerc
  FROM CTE PD
 JOIN avl.prj_configurationprogress CP 
	ON CP.CustomerID = PD.CustomerID AND ScreenID = 1 AND CP.IsDeleted = 0
LEFT JOIN AVL.APP_MAP_ApplicationProjectMapping APM
	ON APM.ProjectID = PD.ProjectID AND APM.IsDeleted = 0	
),
INFRAPCTE AS (
SELECT DISTINCT PD.ProjectID, 
	CASE WHEN TPM.ProjectID IS NOT NULL AND CompletionPercentage < 100 THEN CompletionPercentage + 25
		  WHEN TPM.ProjectID IS NULL AND CompletionPercentage = 100 THEN 75
		 ELSE CompletionPercentage END AS InfraInventoryCompPerc
FROM CTE PD
JOIN avl.prj_configurationprogress CP 
	ON CP.CustomerID = PD.CustomerID AND ScreenID = 17 AND CP.IsDeleted = 0
LEFT JOIN AVL.InfraTowerProjectMapping TPM
	ON TPM.ProjectID = PD.ProjectID AND TPM.IsDeleted = 0
	),

INFRACTE AS (
SELECT DISTINCT  PD.ProjectID , 
			CASE WHEN TM.Customerid IS NOT NULL AND AF.InfraInventoryCompPerc < 100 THEN AF.InfraInventoryCompPerc + 25
			ELSE AF.InfraInventoryCompPerc END AS InfraInventoryCompPerc
from CTE PD
JOIN INFRAPCTE AF on PD.ProjectID=AF.ProjectID
LEFT JOIN AVL.InfraTaskMappingTransaction TM on PD.CustomerID=TM.customerid  AND TM.IsDeleted=0

),

SCOPECTE AS (

SELECT DISTINCT PD.ProjectID, PAV.AttributeValueID AS 'AttributeValueID', ppav.AttributeValueName AS 'AttributeValueName'  
FROM CTE PD
JOIN PP.ProjectAttributeValues PAV ON PAV.ProjectID = PD.ProjectID AND PAV.AttributeID = 1 AND PAV.IsDeleted = 0  
JOIN MAS.PPAttributeValues ppav ON PAV.AttributeValueID = ppav.AttributeValueID    
	AND pav.AttributeID = ppav.AttributeID AND ppav.IsDeleted = 0 AND ppav.AttributeID = 1  
),

ADAPTERCTE AS (
SELECT DISTINCT PD.ProjectID, ISNULL(IsApplensAsALM, 0) AS IsApplensAsALM, 
    CASE WHEN SDALM.ProjectID IS NOT NULL THEN 1 ELSE 0 END AS IsALM,
	CASE WHEN SDITSM.ProjectID IS NOT NULL THEN 1 ELSE 0 END AS IsITSM
FROM CTE PD 
left JOIN PP.ScopeOfWork SCOPE 
	ON SCOPE.ProjectID = PD.ProjectID
LEFT JOIN SCOPECTE SDALM 
	ON SDALM.ProjectID = PD.ProjectID AND SDALM.AttributeValueID IN (1,4) -- ALM
LEFT JOIN SCOPECTE SDITSM 
	ON SDITSM.ProjectID = PD.ProjectID AND SDITSM.AttributeValueID IN (2,3) -- ITSM
	),
ALMCTE AS (
SELECT DISTINCT AC.ProjectID, 
case when P.TileProgressPercentage = 100 then 'Y' else 'N' end as ALMConfig
FROM ADAPTERCTE AC
 left join pp.ProjectProfilingTileProgress P on AC.ProjectID=P.ProjectID and P.TileID='8'
WHERE AC.IsALM = 1
),
ITSMCTE AS (
SELECT DISTINCT AC.ProjectID, 
case when CP.CompletionPercentage = 100 then 'Y' else 'N' end as ITSMStatus
FROM ADAPTERCTE AC
left JOIN avl.prj_configurationprogress CP ON CP.ProjectID = AC.ProjectID AND CP.ScreenID = 2  and ITSMScreenId='11' AND CP.IsDeleted = 0
WHERE AC.IsITSM = 1
),

WRKPRCTE AS (
SELECT DISTINCT AC.ProjectID, 
case when CP.CompletionPercentage = 100 then 'Y' else 'N' end as WorkProfilestatus
FROM CTE AC
left JOIN avl.prj_configurationprogress CP ON CP.ProjectID = AC.ProjectID AND CP.ScreenID = 4  AND CP.IsDeleted = 0
),

FINALCTE AS(
select Distinct PD.ProjectID, PD.esaprojectid ,PD.ProjectName,  
CASE WHEN SupportTypeId = 1 OR SupportTypeId = 4 THEN ISNULL(App.AppInventoryCompPerc, 0)
									 WHEN SupportTypeId = 2 THEN ISNULL(Infra.InfraInventoryCompPerc, 0)
									 WHEN SupportTypeId = 3 THEN (ISNULL(App.AppInventoryCompPerc, 0) + ISNULL(Infra.InfraInventoryCompPerc, 0)) / 2
								END AS AppInventoryCompPerc,
ALM.ALMConfig, ITSM.ITSMStatus,WP.WorkProfilestatus 

from CTE PD
LEFT JOIN APPCTE APP
	ON App.ProjectID = PD.ProjectID
LEFT JOIN INFRACTE Infra 
	ON Infra.ProjectID = PD.ProjectID
LEFT JOIN ALMCTE ALM
	ON ALM.ProjectID = PD.ProjectID
LEFT JOIN ITSMCTE ITSM
	ON ITSM.ProjectID = PD.ProjectID
LEFT JOIN WRKPRCTE WP
	ON WP.ProjectID = PD.ProjectID
)

select Distinct EsaProjectID,ProjectName, 
case when AppInventoryCompPerc is null Then 'N'  when AppInventoryCompPerc =100 Then 'Y' else 'N'  END as 'AppInventory_Status', 
CASE WHEN ALMConfig is NUll then 'NA' else ALMConfig end as ALMConfig_Status,
CASE WHEN ITSMStatus is NULL then 'NA' else ITSMStatus END AS ITSMSTATUS ,WorkProfileStatus
 from FINALCTE;
