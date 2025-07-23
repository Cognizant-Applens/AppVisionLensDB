/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE VIEW [dbo].[VW_Resource_Wise_Effort_Project] AS
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
    JOIN AVL.PRJ_ConfigurationProgress CP1 WITH (NOLOCK) ON CP1.ProjectID = PM.ProjectID 
    AND CP1.ScreenID = 4 
    AND CP1.CompletionPercentage = 100 
    AND cp1.IsDeleted = 0
), 
DATECTE(DATE) AS (
  SELECT 
    DATEADD(
      DAY, 
      -31, 
      CAST(
        GETDATE() AS DATETIME
      )
    ) 
  UNION ALL 
  SELECT 
    date + 1 
  FROM 
    DATECTE 
  WHERE 
    date < DATEADD(
      DAY, 
      -1, 
      CAST(
        GETDATE() AS DATETIME
      )
    )
), 
CTEProjectDate AS (
  SELECT 
    C.EsaProjectID, 
    C.ProjectName, 
    C.ProjectID, 
    CAST(D.date AS DATE) AS ProjectDate 
  FROM 
    DATECTE D CROSS 
    JOIN CTE C
), 
CTETimesheet AS (
  SELECT 
    CTProject.EsaProjectID, 
    CTProject.ProjectName, 
    CTProject.ProjectDate AS 'EffortDate', 
    PD.TimesheetId, 
    LM.EmployeeID, 
    LM.EmployeeName ,
	LM.IsNonESAAuthorized
  FROM 
    CTEProjectDate CTProject 
    LEFT JOIN AVL.TM_PRJ_Timesheet PD WITH (NOLOCK) ON CTProject.ProjectID = PD.ProjectID 
    AND CTProject.ProjectDate = PD.TimesheetDate 
    LEFT JOIN avl.MAS_LoginMaster lm WITH (NOLOCK) ON PD.SubmitterId = LM.UserID
), 
CTEFinal AS (
  SELECT 
    CTProject.EsaProjectID, 
    CTProject.ProjectName, 
    CTProject.EffortDate, 
    --PD.TimesheetId,
    SUM(TD.Hours) AS 'TotalEffort', 
    EmployeeID, 
    EmployeeName ,
	IsNonESAAuthorized
  FROM 
    CTETimesheet CTProject 
    JOIN AVL.TM_TRN_TimesheetDetail TD WITH (NOLOCK) ON CTProject.TimesheetId = TD.TimesheetId 
	
  WHERE 
    TD.IsDeleted = 0 
  GROUP BY 
    CTProject.EsaProjectID, 
    CTProject.ProjectName, 
    CTProject.EffortDate, 
    CTProject.EmployeeID, 
    EmployeeName,
	IsNonESAAuthorized
), 
CTEResult AS (

  SELECT 
    * 
  FROM 
    CTEFinal
) 
SELECT 
  R.EsaProjectID, 
  R.ProjectName, 
  R.EmployeeID AS 'AssociateID', 
  R.EmployeeName AS 'AssociateName', 
  DENSE_RANK() OVER (
    ORDER BY 
      R.EffortDate
  ) AS DayCount, 
  R.EffortDate, 
  R.TotalEffort ,
  R.IsNonESAAuthorized
FROM 
  CTEResult R;
