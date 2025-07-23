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
-- Description:	<To calculate OutBuound Data>
-- =============================================
CREATE PROCEDURE [MS].[Mainspring_DataPushtoOutboundView_Monthly]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--select * from MAP.Mainspring_ServiceMetricBaseMeasureForStandardMetric_MappingN
--select * from MAP.Mainspring_ServiceMetricBaseMeasureForStandardMetric_Mapping
--select * from MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--select * from TRN.Mainspring_ProjectStaging_MonthlyBaseMeasure
--select * from MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_Snapshot
INSERT INTO  MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_Snapshot
SELECT * from MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly

TRUNCATE Table MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly

SELECT  A.* into #Mainspring_ProjectStaging_MonthlyBaseMeasureTemp 
from
(
Select pbm.ProjectStageID, PBM.UniqueName,PSM.ProjectID,PSM.ESAProjectID,PBM.MetricStartDate,PBM.MetricEndDate,
getdate() AS publishedDate,S2M.ServiceOfferingDESC,s1.ServiceName,M1.MetricName,MPM.MainspringPriorityName,
Msc.MainspringSUPPORTCATEGORYName,TLM.MainspringTechnologyLanguageName,m2.MetricTypeDesc,U.UOM_DESC,
B1.BaseMeasureName,PBM.BaseMeasureValue,SM.PositionID,pbm.FrequencyID,PBM.ReportPeriodID,PBM.JobID
,SMOUT.DN_GOALTYPE
From MS.TRN_ProjectStaging_MonthlyBaseMeasure(NOLOCK) PBM

Inner JOIN MS.MAP_ProjectStage_Mapping_Monthly(NOLOCK) PSM ON PBM.ProjectStageID=PSM.ID and psm.IsDeleted = 0
Inner JOIN MS.MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping(NOLOCK) SM ON SM.ServiceMetricBaseMeasureMapID=PSm.ServiceMetricBasemeasureMapID and sm.IsDeleted=0
Inner Join MS.MAP_serviceOffering2withService_Mapping(NOLOCK) S2 on s2.ServiceID=SM.ServiceID
Inner Join MS.MAS_serviceOffering2_Master(NOLOCK) S2M ON S2M.ServiceOffering2ID=S2.ServiceOffering2ID
INNER JOIN AVL.TK_MAS_Service(NOLOCK) S1 ON S1.ServiceID=Sm.ServiceID
INNER JOIN MS.MAS_Metric_Master(NOLOCK) M1 on M1.MetricID=SM.MetricID AND M1.IsDeleted=0
Inner Join MS.MAS_MetricType_Master(NOLOCK) M2 ON m2.MetricTypeID=M1.MetricTypeID
Inner JOIN MS.MAS_UOM_Master(NOLOCK) U ON U.UOMID=M1.UOMID
INNer JOIN MS.MAS_BaseMeasure_Master(NOLOCK) B1 ON B1.BaseMeasureID=Sm.BaseMeasureID AND b1.IsDeleted=0
Inner JOIN MS.MetricstagingMonthlyDump_Outbound(NOLOCK) SMOUT ON SMOUT.DN_UNIQUEKEY=PBM.UniqueName and SMOUT.DN_PROJECTID=PSM.ESAProjectID
Left JOIN MS.MAS_Priority_Master(NOLOCK)  MPM ON MPM.MainspringPriorityID=PSM.M_PRIORITYID
Left JOIN MS.MAS_SUPPORTCATEGORY_Master(NOLOCK) MSC ON MSC.MainspringSUPPORTCATEGORYID=PSM.M_SUPPORTCATEGORY
Left JOIN MS.MAS_TechnologyLanguage_Master(NOLOCK) TLM ON TLM.MainspringTechnologyLanguageName=PSM.M_TECHNOLOGY

) A
	UPDATE ED SET ED.ServiceName=MS.MainspringServiceName FROM   #Mainspring_ProjectStaging_MonthlyBaseMeasureTemp  ED
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
        [CustomValue] = CASE WHEN p.[21] IS NULL THEN NULL ELSE p.[BaseMeasureValue] END,FrequencyID,ReportPeriodID,JobID,DN_GOALTYPE 
FROM (  SELECT   r.ProjectStageID, r.UniqueName,r.ProjectID,r.ESAProjectID,r.MetricStartDate,r.MetricEndDate,r.publishedDate,
r.ServiceOfferingDESC,r.ServiceName,r.MetricName,r.MainspringPriorityName,r.MainspringSUPPORTCATEGORYName,
r.MainspringTechnologyLanguageName,r.MetricTypeDesc,r.UOM_DESC,r.BaseMeasureName,r.BaseMeasureValue,r.PositionID,r.FrequencyID,r.ReportPeriodID,r.JobID,r.DN_GOALTYPE 
       FROM    #Mainspring_ProjectStaging_MonthlyBaseMeasureTemp r  WITH (NOLOCK) ) s
PIVOT ( MAX( s.ProjectStageID )
        FOR s.PositionID IN ( [1], [2], [3], [4], [11], [12], [13], [14], [21] ) ) p
)as PVTResult
ORDER BY PVTResult.Uniquename;

---------------------

SELECT A.* Into #finalTemp FROM (select Distinct UniqueName,ProjectID,ESAProjectID,MetricStartDate,MetricEndDate,publishedDate,
ServiceOfferingDESC,ServiceName,MetricName,MainspringPriorityName,MainspringSUPPORTCATEGORYName,
MainspringTechnologyLanguageName,MetricTypeDesc,UOM_DESC,MAX(NumeratorName1) AS NumeratorName1,MAX(NumeratorValue1) AS NumeratorValue1
,MAX(NumeratorName2) AS NumeratorName2,MAX(NumeratorValue2) AS NumeratorValue2,MAX(NumeratorName3) AS NumeratorName3,MAX(NumeratorValue3) AS NumeratorValue3
,MAX(NumeratorName4) AS NumeratorName4,MAX(NumeratorValue4) AS NumeratorValue4,MAX(DenominatorName1) AS DenominatorName1,MAX(DenominatorValue1) AS DenominatorValue1,
MAX(DenominatorName2) AS DenominatorName2,MAX(DenominatorValue2) AS DenominatorValue2
,MAX(DenominatorName3) AS DenominatorName3,MAX(DenominatorValue3) AS DenominatorValue3,
MAX(DenominatorName4) AS DenominatorName4,MAX(DenominatorValue4) AS DenominatorValue4,MAX(CustomValue) AS CustomValue,
FrequencyID,ReportPeriodID,JobID,DN_GOALTYPE
FROM #LastTemp  WITH (NOLOCK)
GROUP BY UniqueName,ProjectID,ESAProjectID,MetricStartDate,MetricEndDate,publishedDate,
ServiceOfferingDESC,ServiceName,MetricName,MainspringPriorityName,MainspringSUPPORTCATEGORYName,
MainspringTechnologyLanguageName,MetricTypeDesc,UOM_DESC,FrequencyID,ReportPeriodID,JobID,DN_GOALTYPE) AS A
-----------------------
DELETE from #finalTemp where ProjectID in(select projectid from AVL.MAS_ProjectMaster where IsDeleted=1)

Insert into MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
select DISTINCT SM.DN_PROJECTNAME,FT.ProjectID  ,FT.ESAProjectID ,FT.MetricStartDate  ,FT.MetricEndDate  ,FT.publishedDate
      ,FT.ServiceOfferingDESC  ,FT.ServiceName ,FT.MetricName   ,SM.DN_SUPPORTCATEGORY ,SM.DN_PRIORITY
       ,SM.DN_TECHNOLOGY ,SM.DN_MANDATORY,SM.DN_UOM,SM.DN_APPLICABILITY,
       FT.NumeratorName1      ,FT.NumeratorValue1, FT.NumeratorName2      ,FT.NumeratorValue2,
        FT.NumeratorName3      ,FT.NumeratorValue3, FT.NumeratorName4      ,FT.NumeratorValue4,
        FT.DenominatorName1,FT.DenominatorValue1,FT.DenominatorName2,FT.DenominatorValue2,
        FT.DenominatorName3,FT.DenominatorValue3,FT.DenominatorName4,FT.DenominatorValue4
        ,FT.CustomValue, SM.DN_UNIQUEKEY,FT.FrequencyID,FT.ReportPeriodID,FT.JobID,FT.DN_GOALTYPE,SM.DN_BASELINEDATE 
        ,SM.DN_BIC,SM.DN_GOAL,SM.DN_METRICTYPE,SM.DN_CPKGOAL,SM.DN_MINIMUMSERVICETARGET,SM.DN_EXPECTEDSERVICETARGET,SM.DN_GOALLEVEL from 
       #finalTemp FT WITH (NOLOCK)
Inner JOIN MS.[MetricstagingMonthlyDump_Outbound] SM WITH (NOLOCK) ON SM.DN_UNIQUEKEY=FT.UniqueName and FT.ESAProjectID=SM.DN_PROJECTID

--Added for Load Factor metrics-begin
 
 
 -- System type
  
 Insert into  MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly  
select OPS.DN_PROJECTNAME,PBM.ProjectStageID,PM.ESAProjectID ,PBM.MetricStartDate  ,PBM.MetricEndDate  ,getdate()  
        ,null,null ,M1.MetricName,null,null  
        ,null ,OPS.DN_MANDATORY,OPS.DN_UOM,OPS.DN_APPLICABILITY, 
	     null,PBM.BaseMeasureValue,null,null, 
         null,null,null,null, 
         null,null,null,null,  
         null,null,null,null,
         null, OPS.DN_UNIQUEKEY,PBM.FrequencyID,PBM.ReportPeriodID,PBM.JobID,OPS.DN_GOALTYPE,OPS.DN_BASELINEDATE
         ,OPS.DN_BIC,OPS.DN_GOAL,OPS.DN_METRICTYPE,OPS.DN_CPKGOAL,OPS.DN_MINIMUMSERVICETARGET,OPS.DN_EXPECTEDSERVICETARGET,OPS.DN_GOALLEVEL from   
         MS.TRN_ProjectStaging_MonthlyBaseMeasure_LoadFactor(NOLOCK) PBM  
	     INNER JOIN AVL.MAS_ProjectMaster(nolock) PM ON PM.ProjectID =PBM.ProjectStageID
		 INNER JOIN MS.MAS_Metric_Master(NOLOCK) M1 on M1.MetricName=PBM.UniqueName
         Inner JOIN MS.MetricstagingMonthlyDump_Outbound_ProjectSpecific  OPS ON OPS.DN_METRICNAME=PBM.UniqueName 
		 and OPS.DN_MANDATORY in('standard','custom') and PM.ESAProjectID=OPS.DN_PROJECTID
		and  PBM.BaseMeasureValue!=''
		 and (PBM.MetricStartDate is not null or PBM.MetricStartDate!='') 
		 and (PBM.MetricEndDate is not null or PBM.MetricEndDate!='')
-- Manual type


 Insert into MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
select OPS.DN_PROJECTNAME,PBM.ProjectID,PM.ESAProjectID ,PBM.MetricStartDate  ,PBM.MetricEndDate  ,getdate()  
        ,null,null ,M1.MetricName,null,null  
        ,null ,OPS.DN_MANDATORY,OPS.DN_UOM,OPS.DN_APPLICABILITY, 
	     null,PBM.BaseMeasureValue,null,null, 
         null,null,null,null, 
         null,null,null,null,  
         null,null,null,null,
         null, OPS.DN_UNIQUEKEY,PBM.FrequencyID,PBM.ReportPeriodID,PBM.JobID,OPS.DN_GOALTYPE,OPS.DN_BASELINEDATE
         ,OPS.DN_BIC,OPS.DN_GOAL,OPS.DN_METRICTYPE,OPS.DN_CPKGOAL,OPS.DN_MINIMUMSERVICETARGET,OPS.DN_EXPECTEDSERVICETARGET,OPS.DN_GOALLEVEL from   
         MS.TRN_Mainspring_ProjectStaging_BaseMeasure_ProjectSpecific_Manual(NOLOCK) PBM  
	     INNER JOIN AVL.MAS_ProjectMaster(nolock) PM ON PM.ProjectID =PBM.ProjectID
		 INNER JOIN MS.MAS_Metric_Master(NOLOCK) M1 on M1.MetricName=PBM.UniqueName
         Inner JOIN MS.MetricstagingMonthlyDump_Outbound_ProjectSpecific OPS ON OPS.DN_METRICNAME=PBM.UniqueName  
		 and OPS.DN_MANDATORY in('standard','custom') and PM.ESAProjectID=OPS.DN_PROJECTID
		 and  PBM.BaseMeasureValue!=''  
		  and (PBM.MetricStartDate is not null or PBM.MetricStartDate!='') 
		 and (PBM.MetricEndDate is not null or PBM.MetricEndDate!='')
		 
--Added for Load Factor metrics-end	



Drop Table #Mainspring_ProjectStaging_MonthlyBaseMeasureTemp
Drop Table #LastTemp
Drop Table #finalTemp

---------------------------


INSERT INTO MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary_Snapshot
Select * from MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary WITH (NOLOCK)

Truncate Table MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary


SELECT  A.* into #Mainspring_ProjectStaging_MonthlyBaseMeasure_TS_Temp 
from
(
Select pbm.ProjectStageID, PBM.UniqueName,PSM.ProjectID,PSM.ESAProjectID,PBM.MetricStartDate,PBM.MetricEndDate,getdate() AS publishedDate,
S2M.ServiceOfferingDESC,s1.ServiceName,MPM.MainspringPriorityName,Msc.MainspringSUPPORTCATEGORYName,'NA' AS UOM_DESC,
B1.TicketSummaryBaseName,PBM.TicketSummaryValue,B1.BaseStepID,pbm.FrequencyID,PBM.ReportPeriodID,PBM.JobID
From 
MS.TRN_ProjectStaging_MonthlyBaseMeasure_TicketSummary (NOLOCK) PBM
Inner JOIN MS.MAP_TicketSummary_Stage_Mapping_Monthly(NOLOCK) PSM ON PBM.ProjectStageID=PSM.ID AND PSM.IsDeleted=0
--Inner JOIN MAP.Mainspring_ServiceTicketSummaryBase_Mapping(NOLOCK) SM ON SM.ServiceMetricBaseMeasureMapID=PSm.ServiceMetricBasemeasureMapID
Inner Join MS.MAP_serviceOffering2withService_Mapping(NOLOCK) S2 on s2.ServiceID=PSM.ServiceID
Inner Join MS.MAS_serviceOffering2_Master(NOLOCK) S2M ON S2M.ServiceOffering2ID=S2.ServiceOffering2ID
INNER JOIN AVL.TK_MAS_Service(NOLOCK) S1 ON S1.ServiceID=PSM.ServiceID
INNer JOIN MS.MAS_TicketSummaryBase_Master(NOLOCK) B1 ON B1.TicketSummaryBaseID=PSM.TicketSummaryBaseID
Left JOIN MS.MAS_Priority_Master(NOLOCK)  MPM ON MPM.MainspringPriorityID=PSM.M_PRIORITYID
Left JOIN MS.MAS_SUPPORTCATEGORY_Master(NOLOCK) MSC ON MSC.MainspringSUPPORTCATEGORYID=PSM.M_SUPPORTCATEGORY ) A


	UPDATE ED SET ED.ServiceName=MS.MainspringServiceName FROM   #Mainspring_ProjectStaging_MonthlyBaseMeasure_TS_Temp  ED
	INNER JOIN AVL.TK_MAS_Service MS ON ED.ServiceName=MS.ServiceName
	WHERE MS.MainspringServiceName IS 	NOT NULL

--select UniqueName from #Mainspring_ProjectStaging_MonthlyBaseMeasure_TS_Temp where ESAProjectID='2222255794'


select * into #LastTemp_TS
from 
(
 select 
  ProjectStageID, UniqueName,ProjectID,ESAProjectID,MetricStartDate,MetricEndDate,publishedDate,
ServiceOfferingDESC,ServiceName,MainspringPriorityName,MainspringSUPPORTCATEGORYName,UOM_DESC,
TicketSummaryBaseName,TicketSummaryValue,BaseStepID,FrequencyID,ReportPeriodID,JobID  
 from #Mainspring_ProjectStaging_MonthlyBaseMeasure_TS_Temp WITH (NOLOCK)
) src
pivot
(
 MAX(TicketSummaryValue)
  for BaseStepID in ([1], [2], [3],[4],[5])
) piv;

--select * from #LastTemp_TS where ESAProjectID='2222255794'

--select * from #finalTemp_TS where ESAProjectID='2222255794'

SELECT A.* Into #finalTemp_TS FROM (select Distinct UniqueName,ProjectID,ESAProjectID,MetricStartDate,MetricEndDate,publishedDate,
ServiceOfferingDESC,ServiceName,MainspringPriorityName,MainspringSUPPORTCATEGORYName,UOM_DESC
,max([1]) AS NO_OF_TKT_RCVD_IN_MONTH
,max([2]) AS NO_OF_BACKLOG_TKT_FROM_PREVMONTH
,max([3]) AS ACT_TKT_CLSD_IN_CUR_MONTH
,max([4]) AS EXP_NO_OF_TKT_TO_BE_CLSD_IN_CUR_MONTH_AS_PER_SLA
,max([5]) AS ACT_NO_OF_TKT_CLSD_IN_CUR_MONTH_AS_PER_SLA,
FrequencyID,ReportPeriodID,JobID
FROM #LastTemp_TS (NOLOCK) 
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


Insert into MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary
select DISTINCT SM.DN_PROJECTNAME,FT.ProjectID ,FT.ESAProjectID ,FT.MetricStartDate  ,FT.MetricEndDate  ,FT.publishedDate
      ,FT.ServiceOfferingDESC  ,FT.ServiceName  ,SM.DN_SUPPORTCATEGORY ,SM.DN_PRIORITY
       ,SM.DN_MANDATORY,
       FT.NO_OF_TKT_RCVD_IN_MONTH      ,FT.NO_OF_BACKLOG_TKT_FROM_PREVMONTH, FT.ACT_TKT_CLSD_IN_CUR_MONTH   
       ,FT.EXP_NO_OF_TKT_TO_BE_CLSD_IN_CUR_MONTH_AS_PER_SLA,FT.ACT_NO_OF_TKT_CLSD_IN_CUR_MONTH_AS_PER_SLA,
       SM.DN_UNIQUEKEY,FT.FrequencyID,FT.ReportPeriodID,FT.JobID,SM.DN_BASELINEDATE 
        ,SM.DN_BIC,SM.DN_GOAL,SM.DN_METRICTYPE,SM.DN_CPKGOAL,SM.DN_MINIMUMSERVICETARGET,SM.DN_EXPECTEDSERVICETARGET,SM.DN_GOALLEVEL from 
       #finalTemp_TS FT WITH (NOLOCK)
Inner JOIN MS.MetricMasterMonthlyDump_Ticketsummary_Outbound SM  WITH (NOLOCK) ON SM.DN_UNIQUEKEY=FT.UniqueName and SM.DN_PROJECTID=FT.ESAProjectID
AND SM.DN_SUPPORTCATEGORY=FT.MainspringSUPPORTCATEGORYName AND SM.DN_PRIORITY=FT.MainspringPriorityName

--where FT.ESAProjectID='2222255794'

Drop Table #Mainspring_ProjectStaging_MonthlyBaseMeasure_TS_Temp
Drop Table #LastTemp_TS
Drop Table  #finalTemp_TS

--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Numerator1Name=''
--where Numerator1Name is null

--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Numerator2Name=''
--where Numerator2Name is null

--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Numerator3Name=''
--where Numerator3Name is null

--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Numerator4Name=''
--where Numerator4Name is null



--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Numerator1Value=''
--where Numerator1Value is null

--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Numerator2Value=''
--where Numerator2Value is null

--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Numerator3Value=''
--where Numerator3Value is null

--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Numerator4Value=''
--where Numerator4Value is null


--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Denominator1Name =''
--where Denominator1Name is null

--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Denominator2Name=''
--where Denominator2Name is null

--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Denominator3Name=''
--where Denominator3Name is null

--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Denominator4Name=''
--where Denominator4Name is null



--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Denominator1Value=''
--where Denominator1Value is null

--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Denominator2Value=''
--where Denominator2Value is null

--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Denominator3Value=''
--where Denominator3Value is null

--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set Denominator4Value=''
--where Denominator4Value is null

--Update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
--set CustomMetricValue=''
--where CustomMetricValue is null


update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary
set NO_OF_TKT_RCVD_IN_MONTH=NULL
where NO_OF_TKT_RCVD_IN_MONTH='NA'

update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary
set NO_OF_BACKLOG_TKT_FROM_PREVMONTH=NULL
where NO_OF_BACKLOG_TKT_FROM_PREVMONTH='NA'

update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary
set ACT_TKT_CLSD_IN_CUR_MONTH=NULL
where ACT_TKT_CLSD_IN_CUR_MONTH='NA'

update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary
set EXP_NO_OF_TKT_TO_BE_CLSD_IN_CUR_MONTH_AS_PER_SLA=NULL
where EXP_NO_OF_TKT_TO_BE_CLSD_IN_CUR_MONTH_AS_PER_SLA='NA'


update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary
set ACT_NO_OF_TKT_CLSD_IN_CUR_MONTH_AS_PER_SLA=NULL
where ACT_NO_OF_TKT_CLSD_IN_CUR_MONTH_AS_PER_SLA='NA'

update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary
set NO_OF_TKT_RCVD_IN_MONTH=NULL
where NO_OF_TKT_RCVD_IN_MONTH=''

update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary
set NO_OF_BACKLOG_TKT_FROM_PREVMONTH=NULL
where NO_OF_BACKLOG_TKT_FROM_PREVMONTH=''

update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary
set ACT_TKT_CLSD_IN_CUR_MONTH=NULL
where ACT_TKT_CLSD_IN_CUR_MONTH=''

update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary
set EXP_NO_OF_TKT_TO_BE_CLSD_IN_CUR_MONTH_AS_PER_SLA=NULL
where EXP_NO_OF_TKT_TO_BE_CLSD_IN_CUR_MONTH_AS_PER_SLA=''


update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary
set ACT_NO_OF_TKT_CLSD_IN_CUR_MONTH_AS_PER_SLA=NULL
where ACT_NO_OF_TKT_CLSD_IN_CUR_MONTH_AS_PER_SLA=''

update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
 set Numerator1Value = NULL
 where Numerator1Value = ''
 
 update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
 set Numerator2Value = NULL
 where Numerator2Value = ''
 
 update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
 set Numerator3Value = NULL
 where Numerator3Value = ''
 
 
 update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
 set Denominator1Value = NULL
 where Denominator1Value = ''
 
  update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
 set Denominator2Value = NULL
 where Denominator2Value = ''
 
  update MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly
 set Denominator3Value = NULL
 where Denominator3Value = ''
 

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
SET MetricName = REPLACE(MetricName,CHAR(160),CHAR(32))
WHERE MetricName like('%' +  CHAR(160) +'%')

-------Added for date format issue

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator1Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator1Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator1Name = 'Report End Date' and Numerator1Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator1Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator1Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator1Name  = 'Report End Date' and Denominator1Value is NOT NULL

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator2Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator2Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator2Name = 'Report End Date' and Numerator2Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator2Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator2Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator2Name  = 'Report End Date' and Denominator2Value is NOT NULL

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator3Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator3Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator3Name = 'Report End Date' and Numerator3Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator3Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator3Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator3Name  = 'Report End Date' and Denominator3Value is NOT NULL

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator4Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator4Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator4Name = 'Report End Date' and Numerator4Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator4Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator4Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator4Name = 'Report End Date' and Denominator4Value is NOT NULL

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator1Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator1Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator1Name = 'Planned End Date' and Numerator1Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator1Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator1Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator1Name = 'Planned End Date' and Denominator1Value is NOT NULL

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator2Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator2Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator2Name = 'Planned End Date' and Numerator2Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator2Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator2Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator2Name = 'Planned End Date' and Denominator2Value is NOT NULL

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator3Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator3Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator3Name = 'Planned End Date' and Numerator3Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator3Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator3Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator3Name  = 'Planned End Date' and Denominator3Value is NOT NULL

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator4Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator4Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator4Name = 'Planned End Date' and Numerator4Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator4Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator4Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator4Name = 'Planned End Date' and Denominator4Value is NOT NULL


UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator1Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator1Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator1Name = 'Actual End Date' and Numerator1Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator1Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator1Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator1Name = 'Actual End Date' and Denominator1Value is NOT NULL

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator2Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator2Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator2Name = 'Actual End Date' and Numerator2Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator2Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator2Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator2Name = 'Actual End Date' and Denominator2Value is NOT NULL

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator3Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator3Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator3Name = 'Actual End Date' and Numerator3Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator3Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator3Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator3Name  = 'Actual End Date' and Denominator3Value is NOT NULL

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator4Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator4Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator4Name = 'Actual End Date' and Numerator4Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator4Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator4Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator4Name = 'Actual End Date' and Denominator4Value is NOT NULL

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator1Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator1Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator1Name = 'Planned Start Date' and Numerator1Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator1Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator1Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator1Name = 'Planned Start Date' and Denominator1Value is NOT NULL

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator2Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator2Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator2Name = 'Planned Start Date' and Numerator2Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator2Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator2Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator2Name = 'Planned Start Date' and Denominator2Value is NOT NULL

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator3Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator3Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator3Name = 'Planned Start Date' and Numerator3Value is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator3Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator3Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator3Name  = 'Planned Start Date' and Denominator3Value is NOT NULL

UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Numerator4Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Numerator4Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Numerator4Name = 'Planned Start Date' and Numerator4Name is NOT NULL
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
set Denominator4Value = CONVERT(VARCHAR(10),CONVERT(DATETIME,Denominator4Value), 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20),CONVERT(DATETIME,Numerator1Value), 22), 11))
where Denominator4Name = 'Planned Start Date' and Denominator4Value is NOT NULL
--Date format Ends here

  -- Update timestamp as 00:00:00  Monthly start
  
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
SET ReportingMonthEndDate= DATEADD(dd, 0, DATEDIFF(dd, 0, ReportingMonthEndDate))


UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly_TicketSummary
SET ReportingMonthEndDate= DATEADD(dd, 0, DATEDIFF(dd, 0, ReportingMonthEndDate))

DECLARE @ReportEndDate datetime;

set @ReportEndDate= (select top 1 ReportingMonthEndDate from MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly )
UPDATE MS.TRN_APPLENStoMainspringProjectOutBoundData_Monthly 
SET ReportingMonthEndDate= DATEADD(dd, 0, DATEDIFF(dd, 0, @ReportEndDate))
WHERE MetricName='Load Factor'

-- Update timestamp as 00:00:00 monthly end


SET NOCOUNT OFF;  

END

