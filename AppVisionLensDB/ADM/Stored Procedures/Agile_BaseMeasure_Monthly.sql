/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ADM].[Agile_BaseMeasure_Monthly]                  
AS              
BEGIN              
IF OBJECT_ID(N'tempdb..##BaseMeasureTable') IS NOT NULL              
BEGIN              
DROP TABLE ##BaseMeasureTable              
END              
IF OBJECT_ID(N'tempdb..##MetricTable') IS NOT NULL              
BEGIN              
DROP TABLE ##MetricTable              
END                
DECLARE @bmcols AS NVARCHAR(MAX),              
        @bmquery  AS NVARCHAR(MAX),              
  @mcols AS NVARCHAR(MAX),              
        @mquery  AS NVARCHAR(MAX);                     
SELECT @bmcols = STUFF((SELECT DISTINCT ',' + QUOTENAME(BM.BaseMeasureName)               
                   FROM              
      MAS.ADM_Metric_BaseMeasure BM  WITH (NOLOCK) 
	  WHERE BM.ComputeMethodKey In ('SprintVelocityStorypointsaccepted',
									'ImprovedDeploymentPlannedReleases',
									'ImprovedDeploymentActualReleases',
									'ActualUserStoriesCompleted',
									'ActualStoriesCompletedvsCommitted',
									'AdherenceUserStoryAccepted',
									'SprintAutomationActualTestCasesAutomated',
									'SprintAutomationTestCasesAutomatedPerSprint',
									'DefectBacklogCountofOutstandingDefects',
									'DeliveredDefectbyEffortPostShipment',
									'DeliveredDefectbyEffortPostProduction',
									'DeliveredDefectbyEffortActualEffort',
									'PercentageDefectTotalnumberofDefectsCompleted',
									'PercentageDefectTotalnumberofDefectsRejected',
									'PercentageDefectRaisedInQA',
									'PercentageDefectRaisedInUAT',
									'RegressionTestAutomation',
									'RegressionTestCases',
									'QATestStepsOrScenariosExecutedSprint',
									'QATestStepsOrScenariosScopedPlannedExecutedSprint',
									'QATestCasePassed',
									'QANoOfTestCases',
									'ImprovementAverageVelocity',
									'ImprovementBaselineVelocity')           
            FOR XML PATH(''), TYPE              
            ).value('.', 'NVARCHAR(MAX)')               
        ,1,1,'') 
SELECT @mcols = STUFF((SELECT DISTINCT ',' + QUOTENAME(M.MetricName)               
                   FROM              
     MAS.ADM_Metric M   WITH (NOLOCK)              
            FOR XML PATH(''), TYPE              
            ).value('.', 'NVARCHAR(MAX)')               
        ,1,1,'')  
SET @bmquery = N'SELECT               
  EsaProjectID 
 ,ProjectName 
 ,ProjectStatus
 ,Technology
 ,TypeOfProject
 ,ProjectStartDate              
 ,ProjectEndDate           
 ,PTName   
 ,ProjectOwingUnit
 ,MDU
 ,BuisnessName            
 ,VerticalRHMS              
 ,SubVertical 
 ,ParentAccountID
 ,ParentAccount
 ,ClientID
 ,ClientName
 ,ReportingStartDate              
 ,ReportingEndDate              
 ,ReportingPeriod              
 ,ReportingMonth              
 ,ReportingLevel
 ,ReleaseId
 ,ReleaseName
 ,ReleaseStartDate
 ,ReleaseEndDate
 ,ReleaseStatus
 ,SprintDetailsId
 ,SprintId
 ,SprintName
 ,SprintStartDate
 ,SprintEndDate
 ,SprintStatus
 ,ActualEndDate
                
,' + @bmcols + N' into ##BaseMeasureTable from               
             (              
    SELECT DISTINCT               
  MAX(PM.EsaProjectID) AS EsaProjectID
  ,MAX(PM.ProjectName)AS ProjectName
  ,MAX(EA.ProjectStatus) AS ProjectStatus
   ,MAX(OE.Technology) As Technology  
 ,MAX(EA.ProjectType) AS TypeOfProject  
 ,Convert(VARCHAR(20),MAX(EA.ProjectStartDate),101) AS ProjectStartDate              
 ,Convert(VARCHAR(20),MAX(EA.ProjectEndDate),101) AS ProjectEndDate
 ,NULL AS PTName 
 ,MAX(OE.Projectowningunit) AS ProjectOwingUnit
  ,NULL AS MDU
 ,MAX(OE.OwningBU) AS BuisnessName               
 ,MAX(EA.CTS_Vertical) AS VerticalRHMS              
 ,MAX(OE.SubVertical)AS SubVertical   
 ,MAX(C.CustomerID) AS ParentAccountID
 ,MAX(C.CustomerName) AS ParentAccount 
 ,NULL AS ClientID
 ,NULL AS ClientName
 ,Convert(VARCHAR(20),MAX(MMD.MetricStartDate),101) AS ReportingStartDate              
 ,Convert(VARCHAR(20),MAX(MMD.MetricEndDate),101) AS ReportingEndDate              
 ,Convert(VARCHAR(20),MAX(MMD.ReportPeriod),101) AS ReportingPeriod              
 ,DATENAME(month, MAX(MMD.ReportPeriod)) AS ReportingMonth              
 ,NULL AS ReportingLevel   
 ,MAX(CASE WHEN RD.ReleaseDetailsId IS NOT NULL 
		THEN RD.ReleaseId 
		WHEN RI.ReleaseInfoId IS NOT NULL 
		THEN RI.ReleaseId
		ELSE 
		NULL END) AS ReleaseID
 ,MAX(CASE WHEN RD.ReleaseDetailsId IS NOT NULL 
		THEN RD.ReleaseName 
		WHEN RI.ReleaseInfoId IS NOT NULL 
		THEN RI.ReleaseDescription
		ELSE 
		NULL END) AS ReleaseName
  ,MAX(CASE WHEN RD.ReleaseDetailsId IS NOT NULL 
		THEN RD.ActualStartDate 
		WHEN RI.ReleaseInfoId IS NOT NULL 
		THEN RI.ReleaseStartDate
		ELSE 
		NULL END) AS ReleaseStartDate
  ,MAX(CASE WHEN RD.ReleaseDetailsId IS NOT NULL 
		THEN RD.ActualEndDate 
		WHEN RI.ReleaseInfoId IS NOT NULL 
		THEN RI.ReleaseEndDate
		ELSE 
		NULL END) AS ReleaseEndDate
  ,MAX(CASE WHEN RD.ReleaseDetailsId IS NOT NULL 
		THEN MS.SourceName 
		WHEN RI.ReleaseInfoId IS NOT NULL 
		THEN NULL
		ELSE 
		NULL END) AS ReleaseStatus
 ,MAX(CASE WHEN SD.SprintDetailsId IS NOT NULL THEN SD.SprintDetailsId ELSE NULL END) AS SprintDetailsId
 ,MAX(CASE WHEN SD.SprintDetailsId IS NOT NULL THEN SD.SprintId ELSE NULL END) AS SprintID   
 ,MAX(CASE WHEN SD.SprintDetailsId IS NOT NULL THEN SD.SprintName ELSE NULL END) AS SprintName 
 ,MAX(CASE WHEN SD.SprintDetailsId IS NOT NULL THEN SD.SprintStartDate ELSE NULL END) AS SprintStartDate 
 ,MAX(CASE WHEN SD.SprintDetailsId IS NOT NULL THEN SD.SprintEndDate ELSE NULL END) AS SprintEndDate 
 ,MAX(CASE WHEN SD.SprintDetailsId IS NOT NULL THEN AMA.StatusName ELSE NULL END ) AS SprintStatus
 ,Convert(VARCHAR(20),MAX(SD.ActualEndDate),101) AS ActualEndDate
 ,BM.BaseMeasureName AS BaseMeasureName              
 ,MIN(MMD.BaseMeasurevalue)  AS BaseMeasurevalue 
    FROM AVL.MAS_ProjectMaster PM  WITH (NOLOCK)              
    INNER JOIN ESA.Projects EA   WITH (NOLOCK)ON EA.ID = PM.EsaProjectID AND EA.Name = PM.ProjectName              
    INNER JOIN AVL.customer C   WITH (NOLOCK)on C.CustomerID = PM.CustomerID              
    LEFT JOIN MAS.ProjectPracticeMapping PPM   WITH (NOLOCK)ON PPM.ProjectID = PM.ProjectID                
    INNER JOIN  pp.OplEsaData OE   WITH (NOLOCK)ON OE.ProjectID = PM.ProjectID              
    INNER JOIN ADM.TRN_MonthlyProjectMetricDetails MMD   WITH (NOLOCK)ON MMD.MethodologyTypeId=5 AND MMD.ProjectId = PM.ProjectID              
    LEFT JOIN ADM.ALM_TRN_Sprint_Details SD   WITH (NOLOCK)ON SD.SprintDetailsId = MMD.SprintDetailsId 
	LEFT JOIN ADM.ALM_TRN_Release_Details RD   WITH (NOLOCK)ON RD.ReleaseDetailsId = MMD.ReleaseDetailsId
	LEFT JOIN releasecertification.rc.release_info RI   WITH (NOLOCK)ON RI.ReleaseInfoId = MMD.ReleaseInfoId
	LEFT JOIN ADM.MAS_Source MS   WITH (NOLOCK)ON MS.SourceId = RD.StatusId
    LEFT JOIN PP.Alm_Map_Status AMS   WITH (NOLOCK)ON AMS.StatusMapId = SD.StatusId              
    LEFT JOIN PP.Alm_Mas_Status AMA   WITH (NOLOCK)ON AMA.StatusId = AMS.StatusId              
    INNER JOIN MAS.ADM_Metric_BaseMeasure BM   WITH (NOLOCK)ON BM.BaseMeasureId = MMD.BaseMeasureId   
    GROUP BY MMD.SprintDetailsID, PM.ProjectID, MMD.ReleaseInfoId, MMD.ReleaseDetailsId, BM.BaseMeasureName              
                              
            ) x              
            pivot               
            (              
                MAX(BaseMeasurevalue)              
                for BaseMeasureName in (' + @bmcols + N')               
            ) p '              
exec sp_executesql @bmquery;  
        
 DECLARE @resultquery NVARCHAR(MAX);
 SET @resultquery = (
	'select 
	   distinct
	   EsaProjectID AS [ESA PROJECT ID],
	   ProjectName AS [PROJECTNAME],
	   ProjectStatus AS [PROJECT STATUS],
	   Technology AS [TECHNOLOGY],	
	   TypeOfProject AS [TYPEOFPROJECT],
	   ProjectStartDate AS [PROJECT START DATE],
	   ProjectEndDate AS [PROJECT END DATE],
	   PTName AS [PT NAME],	
	   ProjectOwingUnit AS [PROJECT OWNING UNIT],
	   MDU AS [MDU],
	   BuisnessName AS [BUSINESSNAME],
	   VerticalRHMS AS [VERTICALRHMS],
	   SubVertical AS [SUB VERTICAL],
	   ParentAccountID AS [PARENTACCOUNTID],
	   ParentAccount AS [PARENTACCOUNT],
	   ClientID AS [CLIENT ID],
	   ClientName AS [CLIENT NAME],
	   ReportingStartDate AS [REPORTINGSTARTDATE],
	   ReportingEndDate AS [REPORTINGENDDATE],
	   ReportingPeriod AS [REPORTINGPERIOD],
	   ReportingMonth AS [REPORTING_MONTH],
	   ReportingLevel AS [REPORTINGLEVEL],
	   ReleaseId AS [Release ID],
	   ReleaseName AS [Release Name],
	   ReleaseStartDate AS [Release Start Date],
	   ReleaseEndDate AS [Release End Date],
	   ReleaseStatus AS [Release Status],
	   SprintId AS [Sprint ID],	
	   SprintName AS [SPRINT NAME],
	   SprintStartDate AS [Sprint Start Date],
	   SprintEndDate AS [Sprint End Date],
	   SprintStatus AS [Sprint Status],
	   [Number of User Stories Accepted] AS [Accepted User Story Count],
	   [Total number of user stories completed per sprint] AS [Completed User Story Count],
	   [Total number of user stories committed at the beginning of the sprint] AS [Committed User Story Count],
	   [Number of User Stories Accepted] AS [Number of Story Points Accepted],
	   [Total number of user stories committed at the beginning of the sprint] AS [Number of Story Points Committed],
	   [Count of Outstanding (open) Defects at the end of each Sprint] AS [Number of Backlog Defects],
	   [Actual Effort] AS [Actual Effort],	
	   [Number of unique TC or TCPs or Test Steps or Test Scenarios Executed in the Sprint] AS [Number of unique test cases executed],
	   [Number of unique TCs or TCPs or Test Steps or Test Scenarios scoped or planned for Execution in the Sprint] AS [Number of unique test cases scoped or planned],
	   [Number of Actual Test Cases Automated] AS [Number of Actual Test Cases Automated],
	   [Number of Test Cases Automatable per Sprint] AS [Number of Test Cases Automatable per Sprint],
	   [Average Velocity] AS [Average Velocity],
	   [Baseline Velocity] AS [Baseline Velocity],
	   [Number of test cases passed] AS [Number of test cases passed],
	   [Total no of QA test cases] AS [Total no of QA test cases],
	   [No of planned releases in reporting period] AS [No of planned releases in reporting period],
	   [No of actual releases in reporting period] AS [No of actual releases in reporting period],
	   [Number of Post shipment Defects] AS [Number of Post shipment Defects],
	   [Number of Post production Defects] AS [Number of Post production Defects],
	   [Total number of Defects (for the Completed Releases)] AS [Total number of Defects],
	   [Total Number of defects rejected by Development Team] AS [Total Number of defects rejected by Development Team],
	   [Total Number of defects raised in QA] AS [Total Number of defects raised in QA],
	   [Total Number of defects raised in UAT] AS [Total Number of defects raised in UAT],
	   [Number of Regression Test Cases Automated] AS [Number of Regression Test Cases Automated], 
	   [Total no of regression test cases] AS [Total no of regression test cases],	
	   [Total number of Defects (for the Completed Releases)] AS [Total No of Defects],
	   (SELECT [ADM].[GetDevDefects] (SprintDetailsId)) AS [No of Dev Defects],
	   NULL AS [Sigma Original Estimate],
	   NULL AS [Sigma Actual effort],
	   NULL AS [No of Baselined Requirements],
	   SprintEndDate AS [Planned Completion Date],
	   [Total number of user stories completed per sprint] AS [No of Stories Completed],
	   [Total Number of Story points accepted] AS [Number of Story Points],
	   [Total number of user stories committed at the beginning of the sprint] AS [Total No of Stories],
	   NULL AS [No of CQA defects],
	   ActualEndDate AS [Actual Completion Date],
	   [No of actual releases in reporting period] AS [No of Sprints Completed],
	   NULL AS [Cumulative No of requirements changed],
	   NULL AS [Cumulative No of requirements added],
	   NULL AS [Cumulative No of requirements deleted],
	   NULL AS [Commitment Reliability],
	   NULL AS [Adherence to Definition of Done],
	   NULL AS [Actual Stories Completed per Sprint vs Committed Stories],
	   NULL AS [In Sprint Automation],
	   NULL AS [Efforts per Story],
	   NULL AS [Effort Per Story Point],
	   NULL AS [Sprint Velocity],
	   NULL AS [Improvement in Velocity],
	   NULL AS [Code coverage],
	   NULL AS [Defect Backlog in the Sprints],
	   NULL AS [Backlog Defects vs Committed Story Points],
	   NULL AS [Delivered Defect Density by Effort],
	   NULL AS [Percentage Defects leaked to Production],
	   NULL AS [QA Test Case Pass],
	   NULL AS [QA Test Execution Coverage],
	   NULL AS [Regression Test Automation],
	   NULL AS [Improved Deployment Frequency],
	   NULL AS [Team Happiness Index],
	   NULL AS [Percentage Defect Rejected]
 FROM ##BaseMeasureTable BMT')    
 exec sp_executesql @resultquery; 
END
