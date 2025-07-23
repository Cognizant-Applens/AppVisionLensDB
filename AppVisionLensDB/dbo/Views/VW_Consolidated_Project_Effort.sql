/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/


CREATE VIEW [dbo].[VW_Consolidated_Project_Effort] AS
WITH CTE AS (
  SELECT 
    PM.EsaProjectID, 
    PM.ProjectName, 
    PM.ProjectID 
  FROM 
    AVL.MAS_ProjectMaster PM WITH (NOLOCK)
    JOIN AVMDART_MigratedProjectsInfo D WITH (NOLOCK) ON D.ESAProjectID = Pm.EsaProjectID 
    AND D.OperationalDate IS NOT NULL 
    AND PM.IsMigratedFromDART = 1 
    AND PM.IsDeleted = 0 
    AND PM.IsESAProject = 1 
  UNION 
  SELECT 
    PM.EsaProjectID, 
    PM.ProjectName, 
    PM.ProjectID 
  FROM 
    AVL.MAS_ProjectMaster PM WITH (NOLOCK)
    JOIN AVL.PRJ_ConfigurationProgress CP WITH (NOLOCK) ON CP.ProjectID = PM.ProjectID 
    AND CP.ScreenID = 2 
    AND CP.ITSMScreenId = 11 
    AND CP.CompletionPercentage = 100 
    AND CP.IsDeleted = 0 
    AND (
      PM.IsMigratedFromDART = 2 
      OR pm.IsMigratedFromDART IS NULL
    ) 
    AND PM.IsDeleted = 0 
    AND PM.IsESAProject = 1 
    JOIN AVL.PRJ_ConfigurationProgress CP1 ON CP1.ProjectID = PM.ProjectID 
    AND CP1.ScreenID = 4 
    AND CP1.CompletionPercentage = 100 
    AND cp1.IsDeleted = 0
) ,

CTE1 AS(
SELECT 
CTE.ProjectID,
  CTE.EsaProjectID, 
  CTE.ProjectName, 
  SUM(TD.Hours) AS 'TotalActualEffort', 
  CAST(
    GETDATE() AS DATE
  ) AS 'ModifiedOn' 
FROM 
  CTE 
  JOIN AVL.TM_PRJ_Timesheet T WITH (NOLOCK) ON CTE.ProjectID = T.ProjectID 
  JOIN AVL.TM_TRN_TimesheetDetail TD WITH (NOLOCK) ON TD.TimesheetId = T.TimesheetId 
WHERE 
  TD.IsDeleted = 0 
  AND T.TimesheetDate BETWEEN DATEADD(
    DAY, 
    -31, 
    CAST(
      GETDATE() AS DATE
    )
  ) 
  AND DATEADD(
    DAY, 
    -1, 
    CAST(
      GETDATE() AS DATE
    )
  ) 
GROUP BY 
CTE.ProjectID,
  CTE.EsaProjectID, 
  CTE.ProjectName),
  CTE2 AS(
  SELECT 
  C.ProjectID,
  C.EsaProjectID, 
  C.ProjectName, 
  0 AS 'TotalActualEffort', 
  CAST(
    GETDATE() AS DATE
  ) AS 'ModifiedOn' 
FROM 
  CTE C WHERE
   C.ProjectID NOT IN (SELECT CT.ProjectID FROM CTE1 CT)
  )
  SELECT EsaProjectID,projectName,TotalActualEffort,ModifiedOn
   FROM CTE2 UNION SELECT EsaProjectID,projectName,TotalActualEffort,ModifiedOn FROM CTE1;
