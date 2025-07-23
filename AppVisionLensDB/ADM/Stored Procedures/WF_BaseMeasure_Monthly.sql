/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] � [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [ADM].[WF_BaseMeasure_Monthly]             
              
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
     INNER JOIN MAS.ADM_Metric M WITH (NOLOCK) ON M.MetricID = BM.MetricID
	 INNER JOIN ADM.MethodologyMetric_Mapping MMM WITH (NOLOCK) ON MMM.MetricID = BM.MetricID
	 WHERE MMM.MethodologyTypeId =16 and BM.IsDeleted=0
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
 ,ProjectID              
 ,ProjectName              
 ,PTName              
 ,ProjectStatus              
 ,Technology              
 ,ProjectStartDate              
 ,ProjectEndDate              
 ,TypeOfProject              
 ,MarketUnit              
 ,SBU1              
 ,BuisnessName              
 ,Practice              
 ,VerticalRHMS              
 ,SubVertical              
 ,ParentAccount              
 ,ParentAccountID              
 ,ReportingStartDate              
 ,ReportingEndDate              
 ,ReportingPeriod              
 ,ReportingMonth              
 ,REPORTINGLEVEL              
 ,PHASEID              
 ,PHASENAME              
 ,WORKPACKAGETYPE              
 ,WorkPackageId              
 ,WorkPackageName              
 ,ActualStartDate              
 ,ActualEndDate              
 ,WorkPackageStartDate              
 ,WorkPackageEndDate              
 ,LatestBaselinedStartDate              
 ,LatestBaselinedEndDate              
 ,WorkPackageStatus              
 ,SizeUOM              
 ,WorkPackageTechnology              
 ,WorkPackageClosureDate              
 ,MetricReportStatus,              
               
' + @bmcols + N' into ##BaseMeasureTable from               
             (              
    SELECT DISTINCT               
  MAX(PM.EsaProjectID) AS EsaProjectID              
 ,MAX(PM.ProjectID) AS ProjectID              
 ,MAX(PM.ProjectName)AS ProjectName              
 ,'''' AS PTName              
 ,MAX(EA.ProjectStatus) AS ProjectStatus              
 ,MAX(OE.Technology) As Technology              
 ,Convert(VARCHAR(20),MAX(EA.ProjectStartDate),101) AS ProjectStartDate              
 ,Convert(VARCHAR(20),MAX(EA.ProjectEndDate),101) AS ProjectEndDate              
 ,MAX(EA.ProjectType) AS TypeOfProject              
 ,MAX(OE.MarketUnit) AS MarketUnit              
 ,MAX(OE.BU) AS SBU1              
 ,MAX(OE.OwningBU) AS BuisnessName              
 ,MAX(P.PracticeName) AS Practice              
 ,MAX(EA.CTS_Vertical) AS VerticalRHMS              
 ,MAX(OE.SubVertical)AS SubVertical              
 ,MAX(C.CustomerName) AS ParentAccount              
 ,MAX(C.CustomerID) AS ParentAccountID              
 ,Convert(VARCHAR(20),MAX(MMD.MetricStartDate),101) AS ReportingStartDate              
 ,Convert(VARCHAR(20),MAX(MMD.MetricEndDate),101) AS ReportingEndDate              
 ,Convert(VARCHAR(20),MAX(MMD.ReportPeriod),101) AS ReportingPeriod              
 ,DATENAME(month, MAX(MMD.ReportPeriod)) AS ReportingMonth              
 ,'''' AS REPORTINGLEVEL              
 ,'''' AS PHASEID              
 ,'''' AS PHASENAME              
 ,'''' AS WORKPACKAGETYPE              
 ,MAX(MMD.SprintDetailsId) AS WorkPackageId              
 ,MAX(SD.SprintName) AS WorkPackageName              
 ,Convert(VARCHAR(20),MAX(SD.ActualStartDate),101) AS ActualStartDate              
 ,Convert(VARCHAR(20),MAX(SD.ActualEndDate),101) AS ActualEndDate              
 ,Convert(VARCHAR(20),MAX(SD.SprintStartDate),101) AS WorkPackageStartDate              
 ,Convert(VARCHAR(20),MAX(SD.SprintEndDate),101) AS WorkPackageEndDate              
 ,'''' AS LatestBaselinedStartDate              
 ,'''' AS LatestBaselinedEndDate              
 ,MAX(AMA.StatusName) AS WorkPackageStatus              
 ,'''' AS SizeUOM              
 ,'''' AS WorkPackageTechnology            
 ,Convert(VARCHAR(20),MAX(SD.SprintEndDate),101) AS WorkPackageClosureDate              
 ,'''' AS MetricReportStatus              
 ,BM.BaseMeasureName AS BaseMeasureName              
 ,ISNULL(MIN(MMD.BaseMeasurevalue),0)  AS BaseMeasurevalue              
 , MMD.SprintDetailsId              
    FROM AVL.MAS_ProjectMaster PM  WITH (NOLOCK)              
    INNER JOIN ESA.Projects EA   WITH (NOLOCK)ON EA.ID = PM.EsaProjectID AND EA.Name = PM.ProjectName              
    INNER JOIN AVL.customer C   WITH (NOLOCK)on C.CustomerID = PM.CustomerID              
    LEFT JOIN MAS.ProjectPracticeMapping PPM   WITH (NOLOCK)ON PPM.ProjectID = PM.ProjectID              
    LEFT JOIN MAS.Practices P   WITH (NOLOCK)ON P.PracticeID = PPM.PracticeID              
    INNER JOIN  pp.OplEsaData OE   WITH (NOLOCK)ON OE.ProjectID = PM.ProjectID              
    INNER JOIN ADM.TRN_MonthlyProjectMetricDetails MMD   WITH (NOLOCK)ON MMD.MethodologyTypeId=16 AND MMD.ProjectId = PM.ProjectID              
    INNER JOIN ADM.ALM_TRN_Sprint_Details SD   WITH (NOLOCK)ON SD.SprintDetailsId = MMD.SprintDetailsId              
    INNER JOIN PP.Alm_Map_Status AMS   WITH (NOLOCK)ON AMS.StatusMapId = SD.StatusId              
    INNER JOIN PP.Alm_Mas_Status AMA   WITH (NOLOCK)ON AMA.StatusId = AMS.StatusId              
    INNER JOIN MAS.ADM_Metric_BaseMeasure BM   WITH (NOLOCK)ON BM.BaseMeasureId = MMD.BaseMeasureId                
    GROUP BY MMD.SprintDetailsID,BM.BaseMeasureName              
                              
            ) x              
            pivot               
            (              
                MAX(BaseMeasurevalue)              
                for BaseMeasureName in (' + @bmcols + N')               
            ) p '              
exec sp_executesql @bmquery;        
        
                              
select BMT.* FROM ##BaseMeasureTable BMT              
END
