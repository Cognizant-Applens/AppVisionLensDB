/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================  
-- Author: 
-- Create date:
-- Description: <To calculate OutBuound Data>  
-- =============================================  
--EXEC [MS].[Mainspring_DataPushtoOutboundView_Daily]  
CREATE PROCEDURE [MS].[Mainspring_DataPushtoOutboundView_Daily]  
   
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
Insert into MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily_Snapshot  
select * from MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily  WITH(NOLOCK)
  
Truncate table MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily  
  
  
  
SELECT  A.* into #Mainspring_ProjectStaging_TillDateBaseMeasureTemp   
from  
(  
Select pbm.ProjectStageID, PBM.UniqueName,PSM.ProjectID,PSM.ESAProjectID,PBM.MetricStartDate,PBM.MetricEndDate,getdate() AS publishedDate,  
S2M.ServiceOfferingDESC,s1.ServiceName,M1.MetricName,MPM.MainspringPriorityName,Msc.MainspringSUPPORTCATEGORYName,TLM.MainspringTechnologyLanguageName  
,m2.MetricTypeDesc,U.UOM_DESC,B1.BaseMeasureName,PBM.BaseMeasureValue,SM.PositionID,pbm.FrequencyID,PBM.ReportPeriodID,PBM.JobID  
From MS.TRN_ProjectStaging_TillDateBaseMeasure(NOLOCK) PBM  
Inner JOIN MS.MAP_ProjectStage_Mapping(NOLOCK) PSM ON PBM.ProjectStageID=PSM.ID  
Inner JOIN MS.MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping(NOLOCK) SM ON SM.ServiceMetricBaseMeasureMapID=PSm.ServiceMetricBasemeasureMapID  and sm.IsDeleted=0
Inner Join MS.MAP_serviceOffering2withService_Mapping(NOLOCK) S2 on s2.ServiceID=SM.ServiceID  
Inner Join MS.MAS_serviceOffering2_Master(NOLOCK) S2M ON S2M.ServiceOffering2ID=S2.ServiceOffering2ID  
INNER JOIN AVL.TK_MAS_Service(NOLOCK) S1 ON S1.ServiceID=Sm.ServiceID  
INNER JOIN MS.MAS_Metric_Master(NOLOCK) M1 on M1.MetricID=SM.MetricID  
Inner Join MS.MAS_MetricType_Master(NOLOCK) M2 ON m2.MetricTypeID=M1.MetricTypeID  
Inner JOIN MS.MAS_UOM_Master(NOLOCK) U ON U.UOMID=M1.UOMID  
INNer JOIN MS.MAS_BaseMeasure_Master(NOLOCK) B1 ON B1.BaseMeasureID=Sm.BaseMeasureID  
Left JOIN MS.MAS_Priority_Master(NOLOCK)  MPM ON MPM.MainspringPriorityID=PSM.M_PRIORITYID  
Left JOIN MS.MAS_SUPPORTCATEGORY_Master(NOLOCK) MSC ON MSC.MainspringSUPPORTCATEGORYID=PSM.M_SUPPORTCATEGORY  
Left JOIN MS.MAS_TechnologyLanguage_Master(NOLOCK) TLM ON TLM.MainspringTechnologyLanguageName=PSM.M_TECHNOLOGY) A  

	UPDATE ED SET ED.ServiceName=MS.MainspringServiceName FROM  
	#Mainspring_ProjectStaging_TillDateBaseMeasureTemp  ED 
	INNER JOIN AVL.TK_MAS_Service MS ON ED.ServiceName=MS.ServiceName
	WHERE MS.MainspringServiceName IS 	NOT NULL
-------------------------  
  
SELECT PVTResult.* INTO #LastTemp From   
(SELECT UniqueName,ProjectID,ESAProjectID,MetricStartDate,MetricEndDate,publishedDate,  
ServiceOfferingDESC,ServiceName,MetricName,MainspringPriorityName,MainspringSUPPORTCATEGORYName,MainspringTechnologyLanguageName  
,MetricTypeDesc,UOM_DESC,[NumeratorName1] = CASE WHEN p.[1] IS NULL THEN NULL ELSE p.[BaseMeasureName] END,   
        [NumeratorValue1] = CASE WHEN p.[1] IS NULL THEN NULL ELSE p.[BaseMeasureValue] END,  
        [NumeratorName2] = CASE WHEN p.[2] IS NULL THEN NULL ELSE p.BaseMeasureName END,  
        [NumeratorValue2] = CASE WHEN p.[2] IS NULL THEN NULL ELSE p.[BaseMeasureValue] END,   
        [NumeratorName3] = CASE WHEN p.[3] IS NULL THEN NULL ELSE p.BaseMeasureName END,   
        [NumeratorValue3] = CASE WHEN p.[3] IS NULL THEN NULL ELSE p.[BaseMeasureValue] END,   
        [NumeratorName4] = CASE WHEN p.[4] IS NULL THEN NULL ELSE p.BaseMeasureName END,  
        [NumeratorValue4] = CASE WHEN p.[4] IS NULL THEN NULL ELSE p.[BaseMeasureValue] END,   
  [DenominatorName1] = CASE WHEN p.[11] IS NULL THEN NULL ELSE p.BaseMeasureName END,  
        [DenominatorValue1] = CASE WHEN p.[11] IS NULL THEN NULL ELSE p.[BaseMeasureValue] END,  
  [DenominatorName2] = CASE WHEN p.[12] IS NULL THEN NULL ELSE p.BaseMeasureName END,   
        [DenominatorValue2] = CASE WHEN p.[12] IS NULL THEN NULL ELSE p.[BaseMeasureValue] END,    
        [DenominatorName3] = CASE WHEN p.[13] IS NULL THEN NULL ELSE p.BaseMeasureName END,  
        [DenominatorValue3] = CASE WHEN p.[13] IS NULL THEN NULL ELSE p.[BaseMeasureValue] END,  
        [DenominatorName4] = CASE WHEN p.[14] IS NULL THEN NULL ELSE p.BaseMeasureName END,   
        [DenominatorValue4] = CASE WHEN p.[14] IS NULL THEN NULL ELSE p.[BaseMeasureValue] END,   
        [CustomValue] = CASE WHEN p.[21] IS NULL THEN NULL ELSE p.[BaseMeasureValue] END,FrequencyID,ReportPeriodID,JobID   
FROM (  SELECT   r.ProjectStageID, r.UniqueName,r.ProjectID,r.ESAProjectID,r.MetricStartDate,r.MetricEndDate,r.publishedDate,  
r.ServiceOfferingDESC,r.ServiceName,r.MetricName,r.MainspringPriorityName,r.MainspringSUPPORTCATEGORYName,  
r.MainspringTechnologyLanguageName,r.MetricTypeDesc,r.UOM_DESC,r.BaseMeasureName,r.BaseMeasureValue,r.PositionID,r.FrequencyID,r.ReportPeriodID,r.JobID   
       FROM    #Mainspring_ProjectStaging_TillDateBaseMeasureTemp r WITH(NOLOCK)) s  
PIVOT ( MAX( s.ProjectStageID )  
        FOR s.PositionID IN ( [1], [2], [3], [4], [11], [12], [13], [14], [21] ) ) p  
)as PVTResult  
ORDER BY PVTResult.Uniquename;  
  
---------------------  
  
SELECT B.* Into #finalTemp FROM (select Distinct UniqueName,ProjectID,ESAProjectID,MetricStartDate,MetricEndDate,publishedDate,  
ServiceOfferingDESC,ServiceName,MetricName,MainspringPriorityName,MainspringSUPPORTCATEGORYName,  
MainspringTechnologyLanguageName,MetricTypeDesc,UOM_DESC,MAX(NumeratorName1) AS NumeratorName1,MAX(NumeratorValue1) AS NumeratorValue1  
,MAX(NumeratorName2) AS NumeratorName2,MAX(NumeratorValue2) AS NumeratorValue2,MAX(NumeratorName3) AS NumeratorName3,MAX(NumeratorValue3) AS NumeratorValue3  
,MAX(NumeratorName4) AS NumeratorName4,MAX(NumeratorValue4) AS NumeratorValue4,MAX(DenominatorName1) AS DenominatorName1,MAX(DenominatorValue1) AS DenominatorValue1,  
MAX(DenominatorName2) AS DenominatorName2,MAX(DenominatorValue2) AS DenominatorValue2  
,MAX(DenominatorName3) AS DenominatorName3,MAX(DenominatorValue3) AS DenominatorValue3,  
MAX(DenominatorName4) AS DenominatorName4,MAX(DenominatorValue4) AS DenominatorValue4,MAX(CustomValue) AS CustomValue,FrequencyID,ReportPeriodID,JobID  
FROM #LastTemp  WITH(NOLOCK)
GROUP BY UniqueName,ProjectID,ESAProjectID,MetricStartDate,MetricEndDate,publishedDate,  
ServiceOfferingDESC,ServiceName,MetricName,MainspringPriorityName,MainspringSUPPORTCATEGORYName,  
MainspringTechnologyLanguageName,MetricTypeDesc,UOM_DESC,FrequencyID,ReportPeriodID,JobID) AS B  
  
  
-----------------------  

DELETE from #finalTemp where ProjectID in(select projectid from AVL.MAS_ProjectMaster where IsDeleted=1)

  
Insert into MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily  
select SM.DN_PROJECTNAME,FT.ProjectID  ,FT.ESAProjectID ,FT.MetricStartDate  ,FT.MetricEndDate  ,FT.publishedDate  
      ,FT.ServiceOfferingDESC  ,FT.ServiceName ,FT.MetricName   ,FT.MainspringSUPPORTCATEGORYName  ,FT.MainspringPriorityName  
       ,FT.MainspringTechnologyLanguageName ,SM.DN_MANDATORY,SM.DN_UOM,SM.DN_APPLICABILITY,  
       FT.NumeratorName1      ,FT.NumeratorValue1, FT.NumeratorName2      ,FT.NumeratorValue2,  
        FT.NumeratorName3      ,FT.NumeratorValue3, FT.NumeratorName4      ,FT.NumeratorValue4,  
        FT.DenominatorName1,FT.DenominatorValue1,FT.DenominatorName2,FT.DenominatorValue2,  
        FT.DenominatorName3,FT.DenominatorValue3,FT.DenominatorName4,FT.DenominatorValue4  
        ,FT.CustomValue, SM.DN_UNIQUEKEY,FT.FrequencyID,FT.ReportPeriodID,FT.JobID,SM.DN_GOALTYPE,SM.DN_BASELINEDATE
         ,SM.DN_BIC,SM.DN_GOAL,SM.DN_METRICTYPE,SM.DN_CPKGOAL,SM.DN_MINIMUMSERVICETARGET,SM.DN_EXPECTEDSERVICETARGET,SM.DN_GOALLEVEL from   
       #finalTemp FT  WITH(NOLOCK)
Inner JOIN [MS].[MetricstagingDailyDump_Outbound] SM WITH(NOLOCK) ON SM.DN_UNIQUEKEY=FT.UniqueName and sm.DN_MANDATORY in('standard','custom') and FT.ESAProjectID=SM.DN_PROJECTID
  
  
--Added for Load Factor metrics-begin


 Insert into  MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
select OPS.DN_PROJECTNAME,PBM.ProjectStageID,PM.ESAProjectID ,PBM.MetricStartDate  ,PBM.MetricEndDate  ,getdate()  
        ,null,null ,M1.MetricName,null,null  
        ,null ,OPS.DN_MANDATORY,OPS.DN_UOM,OPS.DN_APPLICABILITY, 
	     null,PBM.BaseMeasureValue,null,null, 
         null,null,null,null, 
         null,null,null,null,  
         null,null,null,null,
         null, OPS.DN_UNIQUEKEY,PBM.FrequencyID,PBM.ReportPeriodID,PBM.JobID,OPS.DN_GOALTYPE,OPS.DN_BASELINEDATE
         ,OPS.DN_BIC,OPS.DN_GOAL,OPS.DN_METRICTYPE,OPS.DN_CPKGOAL,OPS.DN_MINIMUMSERVICETARGET,OPS.DN_EXPECTEDSERVICETARGET,OPS.DN_GOALLEVEL from   
         MS.TRN_ProjectStaging_TillDateBaseMeasure_LoadFactor(NOLOCK) PBM  
	     INNER JOIN AVL.MAS_ProjectMaster(nolock) PM ON PM.ProjectID =PBM.ProjectStageID
		INNER JOIN MS.MAS_Metric_Master(NOLOCK) M1 on M1.MetricName=PBM.UniqueName
         Inner JOIN MS.MetricstagingDailyDump_Outbound_ProjectSpecific OPS ON OPS.DN_METRICNAME=PBM.UniqueName
		 and OPS.DN_MANDATORY in('standard','custom') and PM.ESAProjectID=OPS.DN_PROJECTID
		 and PBM.BaseMeasureValue!=''  and (PBM.MetricStartDate is not null or PBM.MetricStartDate!='') 
		 and (PBM.MetricEndDate is not null or PBM.MetricEndDate!='')


--Added for Load Factor metrics-end	
  
Drop Table #Mainspring_ProjectStaging_TillDateBaseMeasureTemp  
Drop Table #LastTemp  
Drop Table #finalTemp  
  
------------------------------------------------------------------------------  
  
INSERT INTO MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily_TicketSummary_Snapshot  
select * from MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily_TicketSummary  
  
  
Truncate table MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily_TicketSummary  
  
  
SELECT  C.* into #Mainspring_ProjectStaging_TillDateBaseMeasure_TS_Temp   
from  
(  
Select pbm.ProjectStageID, PBM.UniqueName,PSM.ProjectID,PSM.ESAProjectID,PBM.MetricStartDate,PBM.MetricEndDate,getdate() AS publishedDate,  
S2M.ServiceOfferingDESC,s1.ServiceName,MPM.MainspringPriorityName,Msc.MainspringSUPPORTCATEGORYName,'NA' AS UOM_DESC,  
B1.TicketSummaryBaseName,PBM.TicketSummaryValue,B1.BaseStepID,pbm.FrequencyID,PBM.ReportPeriodID,PBM.JobID  
From   
MS.TRN_ProjectStaging_TillDateBaseMeasure_TicketSummary (NOLOCK) PBM  
Inner JOIN MS.MAP_TicketSummary_Stage_Mapping(NOLOCK) PSM ON PBM.ProjectStageID=PSM.ID  and PSM.IsDeleted=0
--Inner JOIN MAP.Mainspring_ServiceTicketSummaryBase_Mapping(NOLOCK) SM ON SM.ServiceMetricBaseMeasureMapID=PSm.ServiceMetricBasemeasureMapID  
Inner Join MS.MAP_serviceOffering2withService_Mapping(NOLOCK) S2 on s2.ServiceID=PSM.ServiceID  
Inner Join MS.MAS_serviceOffering2_Master(NOLOCK) S2M ON S2M.ServiceOffering2ID=S2.ServiceOffering2ID  
INNER JOIN AVL.TK_MAS_Service(NOLOCK) S1 ON S1.ServiceID=PSM.ServiceID  
INNer JOIN MS.MAS_TicketSummaryBase_Master(NOLOCK) B1 ON B1.TicketSummaryBaseID=PSM.TicketSummaryBaseID  
Left JOIN MS.MAS_Priority_Master(NOLOCK)  MPM ON MPM.MainspringPriorityID=PSM.M_PRIORITYID  
Left JOIN MS.MAS_SUPPORTCATEGORY_Master(NOLOCK) MSC ON MSC.MainspringSUPPORTCATEGORYID=PSM.M_SUPPORTCATEGORY ) C  
  
 UPDATE ED SET ED.ServiceName=MS.MainspringServiceName FROM  
	#Mainspring_ProjectStaging_TillDateBaseMeasure_TS_Temp  ED
	INNER JOIN AVL.TK_MAS_Service MS ON ED.ServiceName=MS.ServiceName
	WHERE MS.MainspringServiceName IS 	NOT NULL

  
select * into #LastTemp_TS  
from   
(  
 select   
  ProjectStageID, UniqueName,ProjectID,ESAProjectID,MetricStartDate,MetricEndDate,publishedDate,  
ServiceOfferingDESC,ServiceName,MainspringPriorityName,MainspringSUPPORTCATEGORYName,UOM_DESC,  
TicketSummaryBaseName,TicketSummaryValue,BaseStepID,FrequencyID,ReportPeriodID,JobID  
   
 from #Mainspring_ProjectStaging_TillDateBaseMeasure_TS_Temp  WITH (NOLOCK)
) src  
pivot  
(  
 MAX(TicketSummaryValue)  
  for BaseStepID in ([1], [2], [3],[4],[5])  
) piv;  
  
  
  
SELECT A.* Into #finalTemp_TS FROM (select Distinct UniqueName,ProjectID,ESAProjectID,MetricStartDate,MetricEndDate,publishedDate,  
ServiceOfferingDESC,ServiceName,MainspringPriorityName,MainspringSUPPORTCATEGORYName,UOM_DESC  
,max([1]) AS NO_OF_TKT_RCVD_IN_MONTH  
,max([2]) AS NO_OF_BACKLOG_TKT_FROM_PREVMONTH  
,max([3]) AS ACT_TKT_CLSD_IN_CUR_MONTH  
,max([4]) AS EXP_NO_OF_TKT_TO_BE_CLSD_IN_CUR_MONTH_AS_PER_SLA  
,max([5]) AS ACT_NO_OF_TKT_CLSD_IN_CUR_MONTH_AS_PER_SLA,  
FrequencyID,ReportPeriodID,JobID  
FROM #LastTemp_TS  
GROUP BY UniqueName,ProjectID,ESAProjectID,MetricStartDate,MetricEndDate,publishedDate,  
ServiceOfferingDESC,ServiceName,MainspringPriorityName,MainspringSUPPORTCATEGORYName,  
UOM_DESC,FrequencyID,ReportPeriodID,JobID) AS A  
-----------------------  

DELETE from #finalTemp_TS where ProjectID in(select projectid from AVL.MAS_ProjectMaster where IsDeleted=1)

Update #finalTemp_TS
set MainspringSUPPORTCATEGORYName ='NA'
where MainspringSUPPORTCATEGORYName is NULL

Update #finalTemp_TS
set MainspringPriorityName ='NA'
where MainspringPriorityName is NULL
  
Insert into MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily_TicketSummary  
select SM.DN_PROJECTNAME,FT.ProjectID  ,FT.ESAProjectID ,FT.MetricStartDate  ,FT.MetricEndDate  ,FT.publishedDate  
      ,FT.ServiceOfferingDESC  ,FT.ServiceName ,FT.MainspringSUPPORTCATEGORYName  ,FT.MainspringPriorityName  
      ,SM.DN_MANDATORY,  
       FT.NO_OF_TKT_RCVD_IN_MONTH      ,FT.NO_OF_BACKLOG_TKT_FROM_PREVMONTH, FT.ACT_TKT_CLSD_IN_CUR_MONTH     
       ,FT.EXP_NO_OF_TKT_TO_BE_CLSD_IN_CUR_MONTH_AS_PER_SLA,FT.ACT_NO_OF_TKT_CLSD_IN_CUR_MONTH_AS_PER_SLA,  
       SM.DN_UNIQUEKEY,FT.FrequencyID,FT.ReportPeriodID,FT.JobID,SM.DN_BASELINEDATE
        ,SM.DN_BIC,SM.DN_GOAL,SM.DN_METRICTYPE,SM.DN_CPKGOAL,SM.DN_MINIMUMSERVICETARGET,SM.DN_EXPECTEDSERVICETARGET,SM.DN_GOALLEVEL from   
       #finalTemp_TS FT  WITH (NOLOCK)
Inner JOIN [MS].[MetricMasterDailyDump_Ticketsummary_Outbound] SM WITH(NOLOCK) ON SM.DN_UNIQUEKEY=FT.UniqueName  and FT.ESAProjectID=SM.DN_PROJECTID
AND SM.DN_SUPPORTCATEGORY=FT.MainspringSUPPORTCATEGORYName AND SM.DN_PRIORITY=FT.MainspringPriorityName
      
--Drop Table #Mainspring_ProjectStaging_MonthlyBaseMeasure_TS_Temp  
DROP Table #Mainspring_ProjectStaging_TillDateBaseMeasure_TS_Temp
Drop Table #LastTemp_TS  
Drop Table  #finalTemp_TS  
      
      
      Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Numerator1Name=''
where Numerator1Name is null

Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Numerator2Name=''
where Numerator2Name is null

Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Numerator3Name=''
where Numerator3Name is null

Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Numerator4Name=''
where Numerator4Name is null



Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Numerator1Value=''
where Numerator1Value is null

Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Numerator2Value=''
where Numerator2Value is null

Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Numerator3Value=''
where Numerator3Value is null

Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Numerator4Value=''
where Numerator4Value is null


Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Denominator1Name =''
where Denominator1Name is null

Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Denominator2Name=''
where Denominator2Name is null

Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Denominator3Name=''
where Denominator3Name is null

Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Denominator4Name=''
where Denominator4Name is null



Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Denominator1Value=''
where Denominator1Value is null

Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Denominator2Value=''
where Denominator2Value is null

Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Denominator3Value=''
where Denominator3Value is null

Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set Denominator4Value=''
where Denominator4Value is null

Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
set CustomMetricValue=''
where CustomMetricValue is null


update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily_TicketSummary
set NO_OF_TKT_RCVD_IN_MONTH=''
where NO_OF_TKT_RCVD_IN_MONTH='NA'

update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily_TicketSummary
set NO_OF_BACKLOG_TKT_FROM_PREVMONTH=''
where NO_OF_BACKLOG_TKT_FROM_PREVMONTH='NA'

update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily_TicketSummary
set ACT_TKT_CLSD_IN_CUR_MONTH=''
where ACT_TKT_CLSD_IN_CUR_MONTH='NA'

update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily_TicketSummary
set EXP_NO_OF_TKT_TO_BE_CLSD_IN_CUR_MONTH_AS_PER_SLA=''
where EXP_NO_OF_TKT_TO_BE_CLSD_IN_CUR_MONTH_AS_PER_SLA='NA'


update MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily_TicketSummary
set ACT_NO_OF_TKT_CLSD_IN_CUR_MONTH_AS_PER_SLA=''
where ACT_NO_OF_TKT_CLSD_IN_CUR_MONTH_AS_PER_SLA='NA'



UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily 
SET MetricName = REPLACE(MetricName,CHAR(160),CHAR(32))
WHERE MetricName like('%' +  CHAR(160) +'%')

-- Update timestamp as 00:00:00 Daily start
  
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
SET ReportingMonthEndDate= DATEADD(dd, 0, DATEDIFF(dd, 0, ReportingMonthEndDate))


UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily_TicketSummary
SET ReportingMonthEndDate= DATEADD(dd, 0, DATEDIFF(dd, 0, ReportingMonthEndDate))

DECLARE @ReportEndDate datetime;

set @ReportEndDate= (select top 1 ReportingMonthEndDate from MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily)
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily
SET ReportingMonthEndDate= DATEADD(dd, 0, DATEDIFF(dd, 0, @ReportEndDate))
WHERE MetricName='Load Factor' 


  -- Update timestamp as 00:00:00 Daily end



DECLARE @WeekDay INT;

SET @WeekDay=(SELECT DATEPART(DW, GETDATE()))
--SELECT @WeekDay AS [WeekDay]
IF @WeekDay =7
BEGIN
	DECLARE @PublishedDate DATE;
	DECLARE @TodayCount BIGINT;
	SET @TodayCount=(SELECT COUNT(*) FROM MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily(NOLOCK)
						WHERE CONVERT(DATE,PublishedDate)=CONVERT(DATE,GETDATE()))
	SELECT @TodayCount AS TodayCount
	IF @TodayCount >0
	BEGIN
	--to set the end date
	DECLARE @EndDate DATE;
	SET @EndDate=(select convert(date,getdate()-1))
	DECLARE @FormattedDate DATETIME;
	SET @FormattedDate=(SELECT CONVERT(DATETIME,@EndDate))
	SELECT @FormattedDate AS FormattedDate;
	UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily SET ReportingMonthEndDate=@FormattedDate
	WHERE CONVERT(DATE,PublishedDate)=CONVERT(DATE,GETDATE())
	UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Daily_TicketSummary SET ReportingMonthEndDate=@FormattedDate
		WHERE CONVERT(DATE,PublishedDate)=CONVERT(DATE,GETDATE())

/*
delete from [CTSINCHNAVMDBL].[AVMDART].[TRN].[AVMDARTtoMainspring_ProjectOutBoundData_Weekly_AppLens]

delete from [CTSINCHNAVMDBL].[AVMDART].[TRN].[AVMDARTtoMainspring_ProjectOutBoundData_Weekly_TicketSummary_AppLens]

INSERT INTO [CTSINCHNAVMDBL].[AVMDART].[TRN].[AVMDARTtoMainspring_ProjectOutBoundData_Weekly_TicketSummary_AppLens]
(PROJECTNAME,
DARTProjectID,
PROJECTID,
ReportingMonthStartDate,
ReportingMonthEndDate,
PublishedDate,
ServiceOfferingLevel2,
ServiceOfferingLevel3,
SupportCategory,
Priority,
Mandatory,
NO_OF_TKT_RCVD_IN_MONTH,
NO_OF_BACKLOG_TKT_FROM_PREVMONTH,
ACT_TKT_CLSD_IN_CUR_MONTH,
EXP_NO_OF_TKT_TO_BE_CLSD_IN_CUR_MONTH_AS_PER_SLA,
ACT_NO_OF_TKT_CLSD_IN_CUR_MONTH_AS_PER_SLA,
UniqueName,
FrequencyID,
ReportPeriodID,
JobID,
BaselineDate,
DN_BIC,
DN_GOAL,
DN_METRICTYPE,
DN_CPKGOAL,
DN_MINIMUMSERVICETARGET,
DN_EXPECTEDSERVICETARGET,
DN_GOALLEVEL)


SELECT PROJECTNAME,
DARTProjectID,
PROJECTID,
ReportingMonthStartDate,
ReportingMonthEndDate,
PublishedDate,
ServiceOfferingLevel2,
ServiceOfferingLevel3,
SupportCategory,
Priority,
Mandatory,
NO_OF_TKT_RCVD_IN_MONTH,
NO_OF_BACKLOG_TKT_FROM_PREVMONTH,
ACT_TKT_CLSD_IN_CUR_MONTH,
EXP_NO_OF_TKT_TO_BE_CLSD_IN_CUR_MONTH_AS_PER_SLA,
ACT_NO_OF_TKT_CLSD_IN_CUR_MONTH_AS_PER_SLA,
UniqueName,
FrequencyID,
ReportPeriodID,
JobID,
BaselineDate,
DN_BIC,
DN_GOAL,
DN_METRICTYPE,
DN_CPKGOAL,
DN_MINIMUMSERVICETARGET,
DN_EXPECTEDSERVICETARGET,
DN_GOALLEVEL FROM [MS].[TRN_APPLENStoMainspringProjectOutBoundData_Daily_TicketSummary]
 WHERE PROJECTID IN  (
 SELECT EsaProjectID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE IsMainSpringConfigured='Y' AND IsDeleted=0 AND IsODCRestricted='Y'
UNION
SELECT EsaProjectID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE IsMainSpringConfigured='Y' AND IsDeleted=0 AND 
ISNULL(IsODCRestricted,'N') !='Y' AND EsaProjectID IN(
	SELECT 
	PM.EsaProjectID
	FROM 
	AVL.MAS_ProjectMaster PM WITH (NOLOCK)
	INNER JOIN AVL.PRJ_ConfigurationProgress CP WITH (NOLOCK) ON CP.ProjectID = PM.ProjectID 
	AND CP.ScreenID = 2 
	AND CP.ITSMScreenId = 11 
	AND CP.CompletionPercentage = 100 
	AND CP.IsDeleted = 0 
	AND PM.IsDeleted = 0 
	AND PM.IsESAProject = 1 
	INNER JOIN AVL.PRJ_ConfigurationProgress CP1 ON CP1.ProjectID = PM.ProjectID 
	AND CP1.ScreenID = 4 
	AND CP1.CompletionPercentage = 100 
	AND cp1.IsDeleted = 0
)
)

INSERT INTO [CTSINCHNAVMDBL].[AVMDART].[TRN].[AVMDARTtoMainspring_ProjectOutBoundData_Weekly_AppLens]
(PROJECTNAME,
DARTProjectID,
PROJECTID,
ReportingMonthStartDate,
ReportingMonthEndDate,
PublishedDate,
ServiceOfferingLevel2,
ServiceOfferingLevel3,
MetricName,
SupportCategory,
Priority,
Technology,
Mandatory,
MetricUOM,
APPLICABILITY,
Numerator1Name,
Numerator1Value,
Numerator2Name,
Numerator2Value,
Numerator3Name,
Numerator3Value,
Numerator4Name,
Numerator4Value,
Denominator1Name,
Denominator1Value,
Denominator2Name,
Denominator2Value,
Denominator3Name,
Denominator3Value,
Denominator4Name,
Denominator4Value,
CustomMetricValue,
UniqueName,
FrequencyID,
ReportPeriodID,
JobID,
GoalType,
BaselineDate,
DN_BIC,
DN_GOAL,
DN_METRICTYPE,
DN_CPKGOAL,
DN_MINIMUMSERVICETARGET,
DN_EXPECTEDSERVICETARGET,
DN_GOALLEVEL)

SELECT PROJECTNAME,
DARTProjectID,
PROJECTID,
ReportingMonthStartDate,
ReportingMonthEndDate,
PublishedDate,
ServiceOfferingLevel2,
ServiceOfferingLevel3,
MetricName,
SupportCategory,
Priority,
Technology,
Mandatory,
MetricUOM,
APPLICABILITY,
Numerator1Name,
Numerator1Value,
Numerator2Name,
Numerator2Value,
Numerator3Name,
Numerator3Value,
Numerator4Name,
Numerator4Value,
Denominator1Name,
Denominator1Value,
Denominator2Name,
Denominator2Value,
Denominator3Name,
Denominator3Value,
Denominator4Name,
Denominator4Value,
CustomMetricValue,
UniqueName,
FrequencyID,
ReportPeriodID,
JobID,
GoalType,
BaselineDate,
DN_BIC,
DN_GOAL,
DN_METRICTYPE,
DN_CPKGOAL,
DN_MINIMUMSERVICETARGET,
DN_EXPECTEDSERVICETARGET,
DN_GOALLEVEL
FROM [MS].[TRN_APPLENStoMainspringProjectOutBoundData_Daily]
 WHERE PROJECTID IN  (
 SELECT EsaProjectID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE IsMainSpringConfigured='Y' AND IsDeleted=0 AND IsODCRestricted='Y'
UNION
SELECT EsaProjectID FROM AVL.MAS_ProjectMaster(NOLOCK) WHERE IsMainSpringConfigured='Y' AND IsDeleted=0 AND 
ISNULL(IsODCRestricted,'N') !='Y' AND EsaProjectID IN(
	SELECT 
	PM.EsaProjectID
	FROM 
	AVL.MAS_ProjectMaster PM WITH (NOLOCK)
	INNER JOIN AVL.PRJ_ConfigurationProgress CP WITH (NOLOCK) ON CP.ProjectID = PM.ProjectID 
	AND CP.ScreenID = 2 
	AND CP.ITSMScreenId = 11 
	AND CP.CompletionPercentage = 100 
	AND CP.IsDeleted = 0 
	AND PM.IsDeleted = 0 
	AND PM.IsESAProject = 1 
	INNER JOIN AVL.PRJ_ConfigurationProgress CP1 ON CP1.ProjectID = PM.ProjectID 
	AND CP1.ScreenID = 4 
	AND CP1.CompletionPercentage = 100 
	AND cp1.IsDeleted = 0
)
)
*/
	END

END

SET NOCOUNT OFF;  


END

