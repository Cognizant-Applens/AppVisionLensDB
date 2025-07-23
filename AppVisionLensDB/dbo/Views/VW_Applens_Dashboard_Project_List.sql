

CREATE View [dbo].[VW_Applens_Dashboard_Project_List]
AS

With [Applens_Dashboard_Project_List](Month,ESAProjectID,ESA_Project_Name,Mainspring_Project_ID,Execution_Project_Name,ESA_PM_NAME,ESA_PM_ID,Archetype_Cluster,Archetype,Work_Category,
Parent_Account,Practice_Area_PBI,Project_Owning_Unit,Industry_Segment,Vertical,Market,Market_Unit,
Updated_BU,Updated_SBU,ESA_Project_Country,Project_Owner_ESA_PM_department,Project_Owner_Name,Project_Owner_Id,Delivery_Excellence_POC,
Final_Scope,Total_FTE,_3x3_Matrix,Project_Type,Avg_Ticket_Productivity_2023_benchmark,status)
AS
(
SELECT format(DATEADD(month, DATEDIFF(month, 0, Month), 0),'MM-yyyy') as Month,ESA_Project_ID as ESAProjectID,
ESA_Project_Name,Mainspring_Project_ID,Execution_Project_Name,ESA_PM_NAME,ESA_PM_ID,Archetype_Cluster,Archetype,Work_Category,
Parent_Account,Practice_Area_PBI,Project_Owning_Unit,Industry_Segment,Vertical,Market,Market_Unit,
Updated_BU,Updated_SBU,ESA_Project_Country,Project_Owner_ESA_PM_department,Project_Owner_Name,Project_Owner_Id,Delivery_Excellence_POC,
Final_Scope,Total_FTE,_3x3_Matrix,Project_Type,Avg_Ticket_Productivity_2023_benchmark,status
--into #Applens_Dashboard_Project_List
FROM  [dbo].[Applens_Dashboard_Project_List]),

[Total_MPS_Effort_From_Applens](EsaProjectID,Month,Total_MPS_Effort_From_Applens)
AS
(

select distinct C.EsaProjectID ,format(DATEADD(month, DATEDIFF(month, 0, TimesheetDate), 0),'MM-yyyy') AS Month,sum(B.Hours) as  Total_MPS_Effort_From_Applens
--INTO #ApplensTimesheetdetail
from [AVL].[TM_PRJ_Timesheet] A
LEFT JOIN [AVL].[TM_TRN_TimesheetDetail] B ON A.PROJECTID=B.PROJECTID AND A.TimesheetId=B.TimesheetId
lEFT join [AVL].mas_projectmaster C ON C.ProjectID=B.ProjectId
WHERE SERVICEID IN (1,3,4,7,10,11) AND
B.IsDeleted='0' AND C.IsDeleted='0' --and A.TimesheetDate>='01-01-2024' 
--and C.EsaProjectID ='1000169049' --, '1000154883') 
group by C.EsaProjectID,A.ProjectId,DATEADD(month, DATEDIFF(month, 0, A.TimesheetDate), 0)
),


[EDSTimesheetDetailTemp](ESAProjectid,Month,ProjectName,Activitycode,ActivityDescription,Hours,Submitterid,Timesheetstatus,Submitterdate)
AS
(
select ESAProjectid,format(DATEADD(month, DATEDIFF(month, 0, timesheetsubmissiondate), 0),'MM-yyyy') as Month,
ProjectName,Activitycode,ActivityDescription,Hours,Submitterid,Timesheetstatus,Submitterdate
from [$(DiscoverEDSDB)].[EDS].[TimesheetDetail_ALL]
),
[Total_MPS_Effort_from_ESA](ESAProjectid,Month,Total_MPS_Effort_from_ESA)
AS
(

select distinct A.ESAProjectID,A.Month,SUM(B.HOURS) AS Total_MPS_Effort_from_ESA
--INTO #Total_MPS_Effort_from_ESA
from [Applens_Dashboard_Project_List] A  Left join [EDSTimesheetDetailTemp] B
ON A.ESAProjectID=B.ESAProjectid AND A.Month=B.MONTH
WHERE 
B.activitydescription in  ('Problem Management','Incident Management','Service Request Management','Org Change Management','Change & Release Management')
GROUP BY  A.ESAProjectID,A.Month
),
[Effort_Deviation](EsaProjectId,MONTH,Total_MPS_Effort_From_Applens,Total_MPS_Effort_From_ESA,Effort_Deviation)
AS
(

select MA.ESAProjectID as EsaProjectId,MA.MONTH,ISNULL(MA.Total_MPS_Effort_From_Applens,0) AS Total_MPS_Effort_From_Applens ,ISNULL(ME.Total_MPS_Effort_From_ESA,0) AS Total_MPS_Effort_From_ESA,
ISNULL(cast(cast((SUM (MA.Total_MPS_Effort_From_Applens)-SUM (ME.Total_MPS_Effort_From_ESA))*100.00/SUM (MA.Total_MPS_Effort_From_Applens) as decimal(11,1)) as varchar(250)) + '%',0)
AS Effort_Deviation
--INTO #Effort_Deviation
from [Total_MPS_Effort_From_Applens] MA FULL OUTER JOIN [Total_MPS_Effort_from_ESA] ME
ON MA.EsaProjectID=ME.ESAProjectID AND MA.MONTH=ME.MONTH 
GROUP BY  MA.ESAProjectID,MA.MONTH,MA.Total_MPS_Effort_From_Applens,ME.Total_MPS_Effort_From_ESA
),
[Volume](ESAPROJECTID,Month,Volume)
AS
(
select B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, A.OpenDateTime), 0),'MM-yyyy') AS Month ,COUNT(Ticketid) AS Volume
--into #Volume
from [AVL].[TK_TRN_TicketDetail] A
LEFT JOIN AVL.MAS_PROJECTMASTER B ON A.PROJECTID=B.PROJECTID
WHERE SERVICEID IN (1,3,4,7,10,11)  --AND ESAPROJECTID='1000169049'
and A.OpenDateTime>='2024-01-01'
AND A.ISDELETED='0' AND B.ISDELETED='0' --AND A.CLOSEDDATE IS NOT NULL
GROUP BY B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, A.OpenDateTime), 0),'MM-yyyy')
),
[Expected_Volume](ESAPROJECTID,Month,Total_MPS_Effort_From_ESA,Avg_Ticket_Productivity_2023_benchmark,Expected_Volume)
AS
(
select AD.EsaProjectid ,AD.MONTH,ISNULL(ME.Total_MPS_Effort_From_ESA,0) AS Total_MPS_Effort_From_ESA,AD.Avg_Ticket_Productivity_2023_benchmark,
cast(isnull(ME.Total_MPS_Effort_From_ESA*AD.Avg_Ticket_Productivity_2023_benchmark/180,0) as numeric(11)) AS Expected_Volume
--INTO #Expected_Volume
from Applens_Dashboard_Project_List AD FULL OUTER JOIN [Total_MPS_Effort_from_ESA] ME
ON AD.EsaProjectid=ME.EsaProjectid AND AD.MONTH=ME.MONTH 
--WHERE AD.ESA_Project_ID ='1000169049' and AD.month='03-2024'
GROUP BY  AD.EsaProjectid,AD.MONTH,ME.Total_MPS_Effort_From_ESA,AD.Avg_Ticket_Productivity_2023_benchmark
),

[Volume_Deviation](EsaProjectid,MONTH,Volume,Expected_Volume,Volume_Deviation)
AS
(

select EV.EsaProjectid AS EsaProjectid,vol.MONTH,ISNULL(vol.Volume,0) AS Volume ,ISNULL(EV.Expected_Volume,0) AS Expected_Volume,
ISNULL(cast(cast((SUM (vol.Volume)-SUM (EV.Expected_Volume))*100.00/SUM (vol.Volume) as decimal(11,1)) as varchar(250)) + '%',0)
AS Volume_Deviation
from [Volume] vol full outer JOIN [Expected_Volume] EV
ON vol.ESAProjectID=EV.EsaProjectid AND vol.MONTH=EV.MONTH 
--WHERE EV.ESA_Project_ID ='1000236065' and vol.month='01-2024'
GROUP BY  EV.ESAProjectID,vol.MONTH,vol.Volume,EV.Expected_Volume
),

[ApplensTimesheetCompliance](Esaprojectid,Month,Project_Compliance_all)
AS
(
select PC.Esaprojectid,AD.Month,PC.Associate_Project_Compliance_Percent as Project_Compliance_all
from  [Applens_Dashboard_Project_List] AD LEFT JOIN  [$(AdoptionReportDB)].[ADPR].[Project_Compliance_Monthly] PC
ON AD.ESAPROJECTID=PC.ESAPROJECTID AND AD.Month=format(PC.[Created datetime],'MM-yyyy')
),

[Tickets_with_Zero_Effort](ESAPROJECTID,Month,Tickets_with_ZeroEffort)
AS
(
select B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, C.OpenDateTime), 0),'MM-yyyy') AS Month ,COUNT(C.Ticketid) as Tickets_with_ZeroEffort
--into #TicketswithZeroEffort
from [Applens_Dashboard_Project_List] A
LEFT JOIN AVL.MAS_PROJECTMASTER B ON A.ESAPROJECTID=B.ESAPROJECTID
left join [AVL].[TK_TRN_TicketDetail] C ON B.PROJECTID=C.PROJECTID
WHERE  c.OpenDateTime>='2024-01-01' and C.Efforttilldate<=0
AND C.ISDELETED='0' AND B.ISDELETED='0' --AND A.CLOSEDDATE IS NOT NULL
GROUP BY B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, C.OpenDateTime), 0),'MM-yyyy')
),
[Ageing_Tickets](ESAPROJECTID,Month,Ageing_Tickets)
AS
(
select B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, C.OpenDateTime), 0),'MM-yyyy') AS Month ,COUNT(C.Ticketid) as Ageing_Tickets
--into #AgeingTickets
from [Applens_Dashboard_Project_List] A
LEFT JOIN AVL.MAS_PROJECTMASTER B ON A.ESAPROJECTID=B.ESAPROJECTID
left join [AVL].[TK_TRN_TicketDetail] C ON B.PROJECTID=C.PROJECTID
where DATEDIFF(day, c.OpenDateTime, getdate()) >30  and dartstatusid not in (5,8,9) and  c.OpenDateTime>='2024-01-01' --and b.esaprojectid='1000169049'
group by  B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, c.OpenDateTime), 0),'MM-yyyy')
),

[Unknown_Incidents_greater_than_100Hours](ESAPROJECTID,Month,Unknown_Incidents_greater_than_100Hours)
AS
(
select B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, C.OpenDateTime), 0),'MM-yyyy') AS Month ,COUNT(C.Ticketid) as Unknown_Incidents_greater_than_100Hours
--into #UnknownIncidentsgreaterthan100Hours
from [Applens_Dashboard_Project_List] A
LEFT JOIN AVL.MAS_PROJECTMASTER B ON A.ESAPROJECTID=B.ESAPROJECTID
left join [AVL].[TK_TRN_TicketDetail] C ON B.PROJECTID=C.PROJECTID
where C.Efforttilldate>100 and C.serviceid in (4,10) and  C.OpenDateTime>='2024-01-01' --and esaprojectid='1000296355'
group by  B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, C.OpenDateTime), 0),'MM-yyyy')
),
[KnownIncidents_greaterthan_50Hours](ESAPROJECTID,Month,KnownIncidents_greaterthan_50Hours)
AS
(
select B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, C.OpenDateTime), 0),'MM-yyyy') AS Month ,COUNT(C.Ticketid) as KnownIncidents_greaterthan_50Hours
--into #KnownIncidentsgreaterthan50Hours
from [Applens_Dashboard_Project_List] A
LEFT JOIN AVL.MAS_PROJECTMASTER B ON A.ESAPROJECTID=B.ESAPROJECTID
left join [AVL].[TK_TRN_TicketDetail] C ON B.PROJECTID=C.PROJECTID
where C.Efforttilldate>50 and C.serviceid in (1,7) and  C.OpenDateTime>='2024-01-01' --and esaprojectid='1000296355'
group by  B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, C.OpenDateTime), 0),'MM-yyyy')
),
[UNKnownIncidents_greaterthan_0.5Hours](ESAPROJECTID,Month,UNKnownIncidents_greaterthan_HalfHours)
AS
(

select B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, C.OpenDateTime), 0),'MM-yyyy') AS Month ,COUNT(C.Ticketid) as UNKnownIncidents_greaterthan_HalfHours
--into #UnKnownIncidentsgreaterthanHalfanHours
from [Applens_Dashboard_Project_List] A
LEFT JOIN AVL.MAS_PROJECTMASTER B ON A.ESAPROJECTID=B.ESAPROJECTID
left join [AVL].[TK_TRN_TicketDetail] C ON B.PROJECTID=C.PROJECTID
where C.Efforttilldate<0.5 and C.serviceid in (1,7) and  C.OpenDateTime>='2024-01-01' --and esaprojectid='1000296355'
group by  B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, C.OpenDateTime), 0),'MM-yyyy')
),
[Ismo_Associate_Timesheet](ESAPROJECTID,Month,Ismo_Associate_Timesheet)
AS
(
select distinct B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, C.OpenDateTime), 0),'MM-yyyy') AS Month ,count(c.Ticketid) as Ismo_Associate_Timesheet
--into #ISMOAssociatesSubmittedTickets
from [Applens_Dashboard_Project_List] A
Left join esa.projectassociates D on D.projectid=A.ESAPROJECTID
LEFT JOIN AVL.MAS_PROJECTMASTER B ON B.ESAPROJECTID=D.projectid
left join [AVL].[TK_TRN_TicketDetail] C ON B.PROJECTID=C.PROJECTID
where C.serviceid not in (1,7) and D.Dept_name='ADM AVM ISmO' --and b.esaprojectid='1000326970'
group by B.ESAPROJECTID, format(DATEADD(month, DATEDIFF(month, 0, C.OpenDateTime), 0),'MM-yyyy') 
),

[OverallTicketingdataSumTemp](EsaProjectID,Month,TicketswithZeroEffort,AgeingTickets,UnknownIncidentsgreaterthan100Hours,KnownIncidentsgreaterthan50Hours,UnKnownIncidentsgreaterthanHalfanHours,ISMOAssociatesSubmittedTickets)
AS
(
SELECT TE.EsaProjectID,TE.Month,TE.Tickets_with_ZeroEffort,AG.Ageing_Tickets,UH.Unknown_Incidents_greater_than_100Hours,
KI.KnownIncidents_greaterthan_50Hours,UI.UNKnownIncidents_greaterthan_HalfHours,IA.Ismo_Associate_Timesheet
--into #OverallTicketingdataSum
FROM [Tickets_with_Zero_Effort] TE LEFT join Ageing_Tickets AG ON TE.ESAPROJECTID=AG.ESAPROJECTID and TE.Month=AG.Month
LEFT join [Unknown_Incidents_greater_than_100Hours] UH ON UH.ESAPROJECTID=AG.ESAPROJECTID and UH.Month=AG.month
LEFT join [KnownIncidents_greaterthan_50Hours] KI ON KI.ESAPROJECTID=UH.ESAPROJECTID and KI.Month=UH.Month
LEFT join [UNKnownIncidents_greaterthan_0.5Hours] UI ON UI.ESAPROJECTID=KI.ESAPROJECTID AND UI.Month=KI.Month
LEFT join [Ismo_Associate_Timesheet] IA ON IA.ESAPROJECTID=UI.ESAPROJECTID AND IA.MONTH=UI.MONTH
),

[OverallTicketingdataSum](Esaprojectid,Month,DIfferences)
AS
(
 SELECT Esaprojectid,Month,
 SUM(TicketswithZeroEffort+AgeingTickets+UnknownIncidentsgreaterthan100Hours+KnownIncidentsgreaterthan50Hours+UnKnownIncidentsgreaterthanHalfanHours+ISMOAssociatesSubmittedTickets)
 AS DIfferences from [OverallTicketingdataSumTemp]
 group by Esaprojectid,Month
 ),
[Total_Ticket_Volume](ESAPROJECTID,MONTH,Total_TicketVolume)
As
(
 
 SELECT V.ESAPROJECTID,V.MONTH,cast((SUM (V.VOLUME)-SUM (OD.DIfferences)) as decimal(11,1)) as Total_TicketVolume 

 FROM [Volume] V 
 JOIN [OverallTicketingdataSum] OD ON V.ESAPROJECTID=OD.ESAPROJECTID
 group by V.ESAPROJECTID,V.MONTH
),

[Total_Applens_Effort](EsaProjectID,Month,Total_Applens_Effort)
AS
(
select distinct C.EsaProjectID ,
format(DATEADD(month, DATEDIFF(month, 0, TimesheetDate), 0),'MM-yyyy') AS Month,sum(B.Hours) as  Total_Applens_Effort
--INTO #Total_Applens_Effort
from [AVL].[TM_PRJ_Timesheet] A
LEFT JOIN [AVL].[TM_TRN_TimesheetDetail] B ON A.PROJECTID=B.PROJECTID AND A.TimesheetId=B.TimesheetId
lEFT join [AVL].mas_projectmaster C ON C.ProjectID=B.ProjectId
WHERE
B.IsDeleted='0' AND C.IsDeleted='0'
group by C.EsaProjectID,A.ProjectId,DATEADD(month, DATEDIFF(month, 0, A.TimesheetDate), 0)

),

[Total_ESA_Effort](EsaProjectid,Month,Total_ESA_Effort)
AS
(
select distinct A.EsaProjectid,A.Month,SUM(B.HOURS) AS Total_ESA_Effort
--INTO #Total_ESA_Effort
from [Applens_Dashboard_Project_List] A  RIGHT join [EDSTimesheetDetailTemp] B
ON A.EsaProjectid=B.esaprojectid AND A.Month=B.MONTH
GROUP BY  A.EsaProjectid,A.Month
)
--[Effort_Volume_Compliance](Esaprojectid,Month,Effort_Deviation,Volume_Deviation,Compliance)
--AS
--(
--select 
--ED.EsaProjectid,
--ED.Month,
--ED.Effort_Deviation,
--VD.Volume_Deviation,
--  CASE WHEN ED.EFFORT_DEVIATION <=0.25  AND  VD.VOLUME_DEVIATION <=0.25   
--   THEN 'YES' 
--   ELSE 'NO' 
--  END 
--  AS Compliance
--  from [Effort_Deviation] ED FULL OUTER JOIN [Volume_deviation] VD
--ON ED.EsaProjectid=VD.EsaProjectid
--)
select * from(
select distinct
ADP.Esaprojectid,
ADP.MONTH,
ADP.ESA_Project_Name,
ADP.Mainspring_Project_ID,
ADP.Execution_Project_Name,
ADP.ESA_PM_NAME,
ADP.ESA_PM_ID,
ADP.Archetype_Cluster,
ADP.Archetype,
ADP.Work_Category,
ADP.Parent_Account,
ADP.Practice_Area_PBI,
ADP.Project_Owning_Unit,
ADP.Industry_Segment,
ADP.Vertical,
ADP.Market,
ADP.Market_Unit,
ADP.Updated_BU,
ADP.Updated_SBU,
ADP.ESA_Project_Country,
ADP.Project_Owner_ESA_PM_department,
ADP.Project_Owner_Name,
ADP.Project_Owner_Id,
ADP.Delivery_Excellence_POC,
ADP.Final_Scope,
ADP.Total_FTE,
ADP._3x3_Matrix AS '3x3 Matrix',
ADP.Project_Type,
ADP.Avg_Ticket_Productivity_2023_benchmark,
ADP.status,
AE.Total_MPS_Effort_From_Applens,
MP.Total_MPS_Effort_From_ESA, 
ED.Effort_Deviation,
Vol.Volume,
ev.Expected_Volume,
VD.Volume_Deviation,
ATC.Project_Compliance_all,
ZE.Tickets_with_ZeroEffort,
AG.Ageing_Tickets,
UI.Unknown_Incidents_greater_than_100Hours,
KI.KnownIncidents_greaterthan_50Hours,
UIH.UNKnownIncidents_greaterthan_HalfHours,
IA.Ismo_Associate_Timesheet,
OT.DIfferences,
TTV.Total_TicketVolume,
TAE.Total_Applens_Effort,
TEE.Total_ESA_Effort
--EVC.Compliance
from [Applens_Dashboard_Project_List] ADP 
LEFT JOIN [Total_MPS_Effort_From_Applens] AE ON  ADP.ESAPROJECTID=AE.ESAPROJECTID 
LEFT JOIN [Total_MPS_Effort_from_ESA] MP ON MP.ESAPROJECTID=AE.ESAPROJECTID AND MP.MONTH=AE.MONTH
LEFT JOIN [Effort_Deviation] ED ON ED.ESAPROJECTID=MP.ESAPROJECTID AND ED.MONTH=MP.MONTH
LEFT JOIN [Volume] Vol on Vol.esaprojectid=ED.ESAPROJECTID AND VOL.MONTH=ED.MONTH
LEFT JOIN [Expected_Volume] EV on EV.ESAPROJECTID=VOL.ESAPROJECTID AND EV.MONTh=VOL.MONTH
LEFT JOIN [Volume_deviation] vd on vd.esaprojectid=ev.esaprojectid and vd.month=ev.month
LEFT JOIN [ApplensTimesheetCompliance] ATC ON ATC.esaprojectid=vd.esaprojectid and atc.month=vd.month
left join [Tickets_with_Zero_Effort] ze on ze.esaprojectid=atc.esaprojectid and ze.month=atc.month
left join [Ageing_Tickets] ag on ag.esaprojectid=ze.esaprojectid and ag.month=ze.month
left join [Unknown_Incidents_greater_than_100Hours] ui on ui.esaprojectid=ag.esaprojectid and ui.month=ag.month
left join [KnownIncidents_greaterthan_50Hours] ki on ki.esaprojectid=ui.esaprojectid and ki.month=ui.month
left join [UNKnownIncidents_greaterthan_0.5Hours] uih on uih.esaprojectid=ki.esaprojectid and uih.month=ki.month
left join [Ismo_Associate_Timesheet] IA on ia.esaprojectid=uih.esaprojectid and ia.month=uih.month
left join [OverallTicketingdataSum] ot on ot.Esaprojectid=ia.esaprojectid and ot.month=ia.month
left join [Total_Ticket_Volume] ttv on ttv.esaprojectid=ot.esaprojectid and ttv.month=ot.month
left join [Total_Applens_Effort] tae on tae.esaprojectid=ttv.esaprojectid and tae.month=ttv.month
left join [Total_ESA_Effort] tee on tee.esaprojectid=tae.esaprojectid and tee.month=tae.month
--left join [Effort_Volume_Compliance] evc on evc.Esaprojectid=tee.esaprojectid and evc.month=tee.month
) as T
where t.Month is not null
--and t.esaprojectid='1000169049'

