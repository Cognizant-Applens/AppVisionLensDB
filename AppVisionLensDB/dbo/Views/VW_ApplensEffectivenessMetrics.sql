










--select * from dbo.VW_ApplensEffectivenessMetrics where Month='2024-07-01 00:00:00.000' and ESAProjectID='1000000430'
CREATE View [dbo].[VW_ApplensEffectivenessMetrics]
AS

With [EffortComplianceCTE](ESAProjectID,AvailableHours,ActualEffort,StartOfMonth)
AS
(
SELECT 
      [EsaProjectid]
	 ,[Available Hours]    
     ,[Actual Effort]
	 ,DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5,[Startdate]))), 0) AS StartOfMonth
  FROM [$(AdoptionReportDB)].[Adp].[Project_Compliance_Monthly](NOLOCK)
  union
  SELECT 
      [EsaProjectid]
	 ,[Available Hours]    
     ,[Actual Effort] 
     ,DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5,[Startdate]))), 0) AS StartOfMonth
  FROM [$(AdoptionReportDB)].[Adpr].[Project_Compliance_Monthly](NOLOCK)
  union 
  SELECT
      [EsaProjectid]
	  ,[Available Hours] 
	 ,[Actual Effort]
     ,DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5,[Startdate]))), 0) AS StartOfMonth
  FROM [$(AdoptionReportDB)].[Adpr].[Project_Compliance_Weekly](NOLOCK) WHERE
  convert(date,	DATEADD(MINUTE, 30, DATEADD(HOUR, 5, [Created datetime])))
	=(SELECT MAX(convert(date,	DATEADD(MINUTE, 30, DATEADD(HOUR, 5, [Created datetime])))) 
	FROM [$(AdoptionReportDB)].[Adpr].[Project_Compliance_Weekly] ) and 
	(year([Created datetime]) = year(GETDATE()) and day(GETDATE()) <> '5'
	and Month(DATEADD(MINUTE,30,DATEADD(HOUR,5,[Created datetime]))) = Month(DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))))
),
--[EffortCompliance](ESAProjectID,EffortCompliance,StartOfMonth)
--AS
--(
--select ESAProjectID,case when AvailableHours<>0 then sum(ActualEffort)/sum(AvailableHours) else 0 end as EffortCompliance,StartOfMonth from [EffortComplianceCTE]
--Group by ESAProjectID,StartOfMonth,AvailableHours,ActualEffort
--),

[WorkItemOpen](ProjectID,PlannedWorkItem,StartOfMonth)
As
(
 SELECT Project_ID,
 Count(WorkItem_Id) as PlannedWorkItem,
 DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5,Planned_StartDate))), 0) AS StartOfMonth
 FROM ADM.ALM_TRN_WorkItem_Details(NOLOCK)
where Isdeleted=0-- and Project_Id=318
Group by Project_ID,DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5,Planned_StartDate))), 0)
),

[WorkItemClose](ProjectID,ClosedWorkItem,StartOfMonth)
As
(
 SELECT Project_ID,
 Count(WorkItem_Id) as ClosedWorkItem,
 DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5,Actual_EndDate))), 0)AS StartOfMonth
 FROM ADM.ALM_TRN_WorkItem_Details(NOLOCK) WI
inner join PP.ALM_MAP_Status  S ON S.StatusMapId=WI.StatusMapId
where S.StatusID in('4','9') and WI.isdeleted=0
--Isdeleted=0  and StatusMapId in('4','9')-- and project_ID='11742'
Group by Project_ID,DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5,Actual_EndDate))), 0)
),
[WorkItemCloseure](ProjectID,ClosureWorkItem,StartOfMonth)
As
(
 SELECT Project_ID,
 Count(WorkItem_Id) as ClosureWorkItem,
DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5,Planned_StartDate))), 0) AS StartOfMonth
 FROM ADM.ALM_TRN_WorkItem_Details(NOLOCK) WI
 inner join PP.ALM_MAP_Status  S ON S.StatusMapId=WI.StatusMapId
 where WI.Isdeleted=0  and S.StatusID in('4','9')
Group by Project_ID,DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5,Planned_StartDate))), 0)
),

[LoadAccuracy](ESA_ProjectID,StartOfMonth,LoadAccuracyTickets,BaseTickets)
AS
(
SELECT ESA_ProjectID,
CONVERT(date, '01-' + [Period], 103 )as StartOfMonth,
    CurrentValue as LoadAccuracyTickets,
    MaxValue as BaseTickets
FROM [$(ProjectSummaryDB)].[dbo].[ClosureMetrics_Periodic_DataDetails](NOLOCK) where MetricID=4 and IsActive=1 
and MaxValue is not null
),
--[TicketLoadaccuracy](ESA_ProjectID,TicketLoadaccuracy)
--As
--(
--SELECT ESA_ProjectID,case when sum(BaseTickets)>0 then (sum(LoadAccuracyTickets)/sum(BaseTickets))*100 else 0 end 
--FROM [LoadAccuracy]
--group by ESA_ProjectID,BaseTickets,LoadAccuracyTickets,StartOfMonth
--),

[Threshold](EsaProjectID,ThresholdCount)
AS
(
select PDD.EsaProjectID as EsaProjectID,max(ThresholdCount) from 
AVL.DEBT_MAS_HealProjectThresholdMaster Thres,
AVL.MAS_ProjectDebtDetails PDD 
where Thres.IsDeleted = 0 and PDD.IsDeleted = 0
and PDD.ProjectID = Thres.ProjectID
Group by PDD.EsaProjectID,ThresholdCount
),

[ClosureFunctionCompliance](EsaProjectID,ClosureFunctionCompliance,StartOfMonth)
AS
(
SELECT Distinct ProjectID, 
	Count(Status),
	DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5,CreatedDate))), 0) 
	FROM [$(SmartGovernanceDB)].dbo.Closure_SubmissionDetails (NOLOCK)
group by ProjectID,DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5,CreatedDate))), 0) 

),
[Outage](ProjectID,OutageID,StartOfMonth)
As
(
 SELECT Distinct ProjectID, Count(OutageID) as OutageID	,
 DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5,OutageStartTime))), 0) 
from [$(OutageTrackerDB)].[dbo].[OutageDetails] 
where IsActive = 1
group by ProjectID,DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5,OutageStartTime))), 0) 
),
[Getlast24months](ProjectID,StartOfMonth)
AS
(
select distinct P.ProjectID,StartOfMonth from [EffortComplianceCTE] C
inner join AVL.MAS_ProjectMaster(NOLOCK) P ON P.ESAProjectID=C.ESAProjectID
union 
select distinct ProjectID,StartOfMonth from [WorkItemOpen]
union 
select distinct ProjectID,StartOfMonth from [WorkItemClose]

union
select distinct ProjectID,StartOfMonth from [WorkItemCloseure]
union
select distinct P.ProjectID,StartOfMonth from [LoadAccuracy] L
inner join AVL.MAS_ProjectMaster(NOLOCK) P ON P.ESAProjectID=L.ESA_ProjectID
union
select distinct P.ProjectID,StartOfMonth from [ClosureFunctionCompliance] C
inner join AVL.MAS_ProjectMaster(NOLOCK) P ON P.ESAProjectID=C.ESAProjectID
union
select distinct ProjectID,StartOfMonth from [Outage]
)
SELECT distinct * from 
(select distinct
proj.ProjectID,
Proj.ESAProjectID,
GM.StartOfMonth as [Month],
isnull(EC.AvailableHours,0) as AvailableHours,
isnull(EC.ActualEffort,0) as ActualEffort,
isnull(WIO.PlannedWorkItem,0) as Workitemopened,
isnull(WIC.ClosedWorkItem,0) as Workitemclosed,
isnull(WICo.ClosureWorkItem,0) as WorkItemClosure,
isnull(TLA.LoadAccuracyTickets,0)as LoadAccuracyTickets,
isnull(TLA.BaseTickets,0)as BaseTickets,
--T.ThresholdCount as [Pattern Frequency Threshold],
isnull(CFC.ClosureFunctionCompliance,0)as ClosureFunctionCompliance,
(O.OutageID) as OutageID
--  case when EC.StartOfMonth is not null then EC.StartOfMonth
--when WIO.StartOfMonth is not null then WIO.StartOfMonth when WIC.StartOfMonth is not null then WIC.StartOfMonth
--when  TLA.StartOfMonth is not null then TLA.StartOfMonth 
--when  CFC.StartOfMonth is not null then CFC.StartOfMonth 
--else O.StartOfMonth end as[Month]
from  AVL.MAS_ProjectMaster(NOLOCK)  Proj 
left join [Getlast24months] GM ON GM.ProjectID=Proj.ProjectID
left join [EffortComplianceCTE] EC ON EC.ESAProjectID=Proj.ESAProjectID and EC.StartOfMonth=GM.StartOfMonth
left Join [WorkItemOpen] WIO ON WIO.ProjectID=Proj.ProjectID and GM.StartOfMonth=WIO.StartOfMonth
left join [WorkItemClose] WIC ON WIC.ProjectID=Proj.ProjectID and GM.StartOfMonth=WIC.StartOfMonth
left join [WorkItemCloseure] WICo ON WICo.ProjectID=Proj.ProjectID and GM.StartOfMonth=WICo.StartOfMonth
left Join [LoadAccuracy]TLA ON TLA.ESA_ProjectID=Proj.ESAProjectID and TLA.StartOfMonth=GM.StartOfMonth
--left Join [Threshold] T ON T.EsaProjectID=Proj.ESAProjectID
left Join [ClosureFunctionCompliance]CFC ON CFC.ESAProjectID=Proj.ESAProjectID and GM.StartOfMonth=CFC.StartOfMonth
left Join [Outage] O ON O.ProjectID=Proj.ProjectID and O.StartOfMonth=GM.StartOfMonth
WHERE Proj.Isdeleted=0 )as t
where t.[Month] is not null
--Group by WIC.StartOfMonth,WIO.StartOfMonth,TLA.StartOfMonth,Proj.ESAProjectID
