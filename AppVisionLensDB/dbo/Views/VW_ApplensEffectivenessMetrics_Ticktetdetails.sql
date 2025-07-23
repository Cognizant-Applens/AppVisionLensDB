CREATE View [dbo].[VW_ApplensEffectivenessMetrics_Ticktetdetails]
AS

WITH [TicketDetailsBase](TicketID,ProjectID,DARTStatusID,opendatetime,Closeddate,ServiceID,IsDeleted,IsPartiallyAutomated,DebtClassificationMode,
AvoidableFlag,ResidualDebtMapID,DebtClassificationMapID,ApplicationID,TicketTypeMapID)
As
(
SELECT   (TicketID),TD.ProjectID,DARTStatusID,DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5, opendatetime))), 0),
DATEADD(month, DATEDIFF(month, 0,DATEADD(MINUTE, 30, DATEADD(HOUR, 5, Closeddate))), 0)
,ServiceID,TD.IsDeleted,IsPartiallyAutomated,
DebtClassificationMode,AvoidableFlag,ResidualDebtMapID,DebtClassificationMapID,ApplicationID,TicketTypeMapID
FROM AVL.TK_TRN_TicketDetail(NOLOCK) TD
where DATEADD(MINUTE, 30, DATEADD(HOUR, 5, OpenDateTime)) >= DATEADD(year,-2,DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))) and TD.Isdeleted=0 
--group by TD.ProjectID,DARTStatusID,DATEADD(month, DATEDIFF(month, 0, opendatetime), 0),DATEADD(month, DATEDIFF(month, 0, Closeddate), 0),
--ServiceID,TD.IsDeleted,IsPartiallyAutomated,
--DebtClassificationMode,AvoidableFlag,ResidualDebtMapID,DebtClassificationMapID,ApplicationID,TicketTypeMapID
),
[TicketDetails](ProjectID,TotalTickets,Open_DARTStatusID,StartOfMonth)
As
(
SELECT 
ProjectID,
count(TicketID) as TotalTickets,
DARTStatusID as Open_DARTStatusID,
DATEADD(month, DATEDIFF(month, 0, opendatetime), 0) AS StartOfMonth
FROM [TicketDetailsBase]
where Isdeleted=0 and DARTStatusID not in ('13')
Group by ProjectID ,DARTStatusID,DATEADD(month, DATEDIFF(month, 0, opendatetime), 0) 
),
[TicketCount](ProjectID,TicketOpen,TicketClosenume,TicketClosedeno,StartOfMonth)
As
(
select Projectid,
sum(CASE when Open_DARTStatusID not in('13','5','7') then (TotalTickets) end) as TicketOpen,
CAST(sum(CASE WHEN Open_DARTStatusID in('8') then (TotalTickets) end)as float) as TicketClosenume,
cast(NULLIF(sum(CASE WHEN Open_DARTStatusID not in('13','5','7')then (TotalTickets)end ),0)as float) as TicketClosedeno
,StartOfMonth
FROM [TicketDetails]
group by Projectid,StartOfMonth
),
[GetLast2yrsMonths](Monthdate) 
 AS
(
   SELECT DATEADD(month, DATEDIFF(month, 0, eomonth(DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())),-23)), 0) AS Monthdate
    UNION ALL
    SELECT DATEADD(MONTH, 1, Monthdate)
        FROM [GetLast2yrsMonths]
        WHERE ( DATEADD(MONTH, 1, Monthdate) <=  EOMONTH(DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())))) 
        
),
[DebtTicketsOpened](ProjectID,TotaldebtTickets, Debt_Opened_Month,Backlog_CloseMY,DARTStatusID)
AS
(
SELECT
TD.ProjectID,
count(distinct TicketID) as TotaldebtTickets, 
 DATEADD(month, DATEDIFF(month, 0, OpenDateTime), 0) AS Debt_Opened_Month,
 DATEADD(month, DATEDIFF(month, 0, Closeddate), 0) AS Backlog_CloseMY,
 DARTStatusID
FROM [TicketDetailsBase] TD
Where DARTStatusID not in('13','5','7') 
and ServiceID in('1','4','5','6','8','7','10') --and Proj.isdeleted=0
Group by TD.ProjectID ,
 DATEADD(month, DATEDIFF(month, 0, OpenDateTime), 0) , DATEADD(month, DATEDIFF(month, 0, Closeddate), 0) ,DARTStatusID
),
[DebtTicketsOpenedColumns](ProjectID,Debt_Open_Tickets,StartOfMonth)
AS
(
SELECT ProjectID ,sum(CASE WHEN Debt_Opened_Month = Monthdate  then (TotaldebtTickets)end) as Debt_Open_Tickets, Debt_Opened_Month
FROM [DebtTicketsOpened] A
left join [GetLast2yrsMonths] G ON G.Monthdate=A.Debt_Opened_Month 
Group by ProjectID,Debt_Opened_Month
),
[Debt_Tickets_Closed](ProjectID,TotaldebtClosedTickets,StartOfMonth)
AS
(
SELECT 
TD.ProjectID,
count(TicketID) as	TotaldebtClosedTickets, 
DATEADD(month, DATEDIFF(month, 0, Closeddate), 0) AS StartOfMonth
FROM [TicketDetailsBase] TD
WHERE DARTStatusID in('8')
and ServiceID in('1','4','5','6','8','7','10') --and Proj.isdeleted=0
Group by TD.ProjectID ,DATEADD(month, DATEDIFF(month, 0, Closeddate), 0)
),
[Debt_Tickets_ClosedColumns](ProjectID,DebtTicketClosed,StartOfMonth)
AS
(
SELECT 
ProjectID,
sum(TotaldebtClosedTickets), 
StartOfMonth
FROM [Debt_Tickets_Closed] 
Group by ProjectID ,StartOfMonth
),
[BacklogTickets](ProjectID,BacklogTickets,StartOfMonth)
AS
(
SELECT ProjectID,sum(TotaldebtTickets), DATEADD(month, DATEDIFF(month, 0, Monthdate), 0)
FROM [DebtTicketsOpened] TD
left join [GetLast2yrsMonths] G on DATEADD(month, DATEDIFF(month, 0, TD.Debt_Opened_Month), 0)>= Dateadd(Month, Datediff(Month, 0, DATEADD(m, -6,
G.Monthdate)), 0) and  DATEADD(month, DATEDIFF(month, 0, TD.Debt_Opened_Month), 0)<G.Monthdate 
where   
  ((DARTStatusID<>8 and Backlog_CloseMY is null)or (DARTStatusID=8 
and DATEADD(month, DATEDIFF(month, 0, TD.Backlog_CloseMY), 0)  >=G.Monthdate)or
(DARTStatusID=2 and DATEADD(month, DATEDIFF(month, 0, TD.Backlog_CloseMY), 0)<=G.Monthdate) )
group by ProjectID,DATEADD(month, DATEDIFF(month, 0, Monthdate), 0)
),

[MachineResolvedtemp](ProjectID,MachineResolved,StartOfMonth)
AS
(
SELECT ProjectID,Count(ticketID),DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5, Closeddate))), 0)
FROM AVL.TK_TRN_BOTTicketDetail
WHERE Isdeleted=0 and SupportType=1 or SupportType is null
Group by ProjectID,DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5, Closeddate))), 0)
),
[MachineResolved](ProjectID,MachineResolved,StartOfMonth)
AS
(
SELECT ProjectID,sum(MachineResolved),StartOfMonth
FROM [MachineResolvedtemp] 
Group by ProjectID,StartOfMonth
),
[MachineAssistedtemp](ProjectID,MachineAssisted,StartOfMonth)
AS
(
SELECT 
TD.ProjectID,
count(TicketID) as	MachineAssisted,DATEADD(month, DATEDIFF(month, 0, Closeddate), 0) 
FROM [TicketDetailsBase] TD
left join AVL.MAS_ProjectMaster(NOLOCK)  Proj ON Proj.ProjectID=TD.ProjectID
WHERE DARTStatusID in('8') and IsPartiallyAutomated='1'
group by DATEADD(month, DATEDIFF(month, 0, Closeddate), 0) ,TD.projectID
),
[MachineAssisted](ProjectID,MachineAssisted,StartOfMonth)
AS
(
SELECT 
TD.ProjectID,
sum(MachineAssisted) as	MachineAssisted,StartOfMonth
FROM [MachineAssistedtemp] TD
Group by TD.ProjectID,StartOfMonth
),
[AnalystResolvedtemp](ProjectID,AnalystResolved,StartOfMonth)
AS
(
SELECT 
TD.ProjectID,
count(TicketID) as	AnalystResolved,DATEADD(month, DATEDIFF(month, 0, Closeddate), 0)
FROM [TicketDetailsBase] TD
left join AVL.MAS_ProjectMaster(NOLOCK)  Proj ON Proj.ProjectID=TD.ProjectID
WHERE DARTStatusID in('8') and (IsPartiallyAutomated not in('1') or IsPartiallyAutomated is null)
group by DATEADD(month, DATEDIFF(month, 0, Closeddate), 0) ,TD.projectID
),
[AnalystResolved](ProjectID,AnalystResolved,StartOfMonth)
AS
(
SELECT 
TD.ProjectID,
sum(AnalystResolved) as	AnalystResolved,StartOfMonth
FROM [AnalystResolvedtemp] TD
Group by TD.ProjectID,StartOfMonth
),


[Ispacetemp](ProjectID,OpportunitiesPushedtoispace,StartOfMonth)
As
(
select B.ProjectID,COUNT(HT.HealingTicketID) as OpportunitiesPushedtoispace,DATEADD(month, DATEDIFF(month, 0,DATEADD(MINUTE, 30, DATEADD(HOUR, 5,A.TriggeredDate))), 0) 
 from AVL.DEBT_MAS_ReleasePlanDetails(NOLOCK) A 
 Join AVL.DEBT_TRN_HealTicketDetails(NOLOCK) HT on A.ID=HT.Releaseplanning
join AVL.MAS_ProjectMaster (NOLOCK) B on a.ProjectId = b.ProjectID
where A.TriggeredDate is not null and A.TicketType='A'
and B.IsDeleted=0  
group by B.ProjectID,DATEADD(month, DATEDIFF(month, 0, 	DATEADD(MINUTE, 30, DATEADD(HOUR, 5, A.TriggeredDate))), 0) 
),
[Ispace](ProjectID,OpportunitiesPushedtoispace,StartOfMonth)
As
(
select ProjectID,sum(OpportunitiesPushedtoispace) as OpportunitiesPushedtoispace,StartOfMonth
 from [Ispacetemp]
  
group by ProjectID,StartOfMonth
),

[DEBT_CLASSIFICATION](ProjectID,TotalDebtClassified,DebtClassificationMode1,Debt_AvoidableFlag,Debt_ResidualDebtMapID,IsMLSignOff,StartOfMonth)
AS
(
SELECT TD.ProjectID,
count(TicketID) as	TotalDebtClassified, 
DebtClassificationMode as DebtClassificationMode1,
AvoidableFlag as Debt_AvoidableFlag,
ResidualDebtMapID as Debt_ResidualDebtMapID,
--1 as IsMLSignOff,
isnull(PD.IsMLSignOff,0),
DATEADD(month, DATEDIFF(month, 0, Closeddate), 0)
From [TicketDetailsBase] TD
left join AVL.MAS_ProjectDebtDetails PD ON PD.ProjectID=TD.ProjectID
WHERE DARTStatusID=8 And DebtClassificationMapID in('1','2','3','4')
		And AvoidableFlag is not null
		And ApplicationID<>'0'
		And ResidualDebtMapID is not null
        And ServiceID in('1','4','5','6','8','7','10')
		group by DATEADD(month, DATEDIFF(month, 0, Closeddate), 0),DebtClassificationMode,AvoidableFlag,ResidualDebtMapID,TD.ProjectID,PD.IsMLSignOff 
),
[Debt_Columns](ProjectID,AvoidableTickets,AutomatableTickets,AutoDebtClassification,
ResidualTickets,Debt_deno,StartOfMonth)
AS
(
SELECT ProjectID,isnull(sum(CASE WHEN Debt_AvoidableFlag='2' and Debt_ResidualDebtMapID='2' 
then (TotalDebtClassified)end),0) as AvoidableTickets,
isnull(sum(CASE WHEN Debt_AvoidableFlag='3' and Debt_ResidualDebtMapID='2' 
then (TotalDebtClassified)end ),0)as AutomatableTickets,
(isnull(sum(CASE WHEN DebtClassificationMode1='3' then (TotalDebtClassified)end),0)+
isnull(sum(CASE WHEN IsMLSignOff=1 and DebtClassificationMode1='1' then (TotalDebtClassified) end ),0)) as AutoDebtClassification,
isnull(sum(CASE WHEN Debt_ResidualDebtMapID='1' then (TotalDebtClassified) end ),0)as ResidualTickets,
isnull(sum(TotalDebtClassified),0) as Debt_deno,
StartOfMonth
FROM [DEBT_CLASSIFICATION]
Group by ProjectID,StartOfMonth

),
[Ticket_Classifier](ProjectID,TicketClassifier,DARTStatusID,TicketID,StartOfMonth)
AS
(
SELECT TD.ProjectID,CASE WHEN ServiceID= 1 or ServiceID= 4 then'Incident'
WHEN ServiceID= 3 then 'Problem' WHEN ServiceID= 7 or ServiceID= 10 then 'Service Request'
WHEN ServiceID= 11 then 'Change Request' else 'Others'end as [TicketClassifier], --Fix
--WHEN AVMTicketType= 2 then 'Incident' WHEN AVMTicketType= 3 then 'Problem' WHEN AVMTicketType= 1 then'Service Request'
--WHEN AVMTicketType= 4 then 'Change Request' else 'Others'end as [TicketClassifier],
DARTStatusID,TicketID,DATEADD(month, DATEDIFF(month, 0, opendatetime), 0)
FROM [TicketDetailsBase] TD 
left join AVL.TK_MAP_TicketTypeMapping TM ON TM.TicketTypeMappingID=TD.TicketTypeMapID
where supporttypeid in(1,3)
),
[Debt_ClosedTickets](ProjectID,Debt_ClosedTickets,StartOfMonth)
AS
(
SELECT ProjectID ,
COUNT(TicketID),StartOfMonth
FROM [Ticket_Classifier]
where DARTStatusID in('8') and TicketClassifier in('Incident','Service Request')
Group by ProjectID ,StartOfMonth
),
[Getlast24months](ProjectID,StartOfMonth)
AS
(
select distinct ProjectID,cast(StartOfMonth as date) from [TicketCount] 
union 
select distinct ProjectID,cast(StartOfMonth as date) from [Debt_Tickets_ClosedColumns]
union 
select distinct ProjectID,cast(StartOfMonth as date) from [DebtTicketsOpenedColumns]
union
select distinct ProjectID,cast(StartOfMonth as date) from [BacklogTickets] 
union
select distinct ProjectID,cast(StartOfMonth as date) from [MachineResolved] 
union
select distinct ProjectID,cast(StartOfMonth as date) from [MachineAssisted]
union
select distinct ProjectID,cast(StartOfMonth as date) from [AnalystResolved] 
union
select distinct ProjectID,cast(StartOfMonth as date) from [Debt_Columns]
union
select distinct ProjectID,cast(StartOfMonth as date) from [Debt_ClosedTickets]
union
select distinct ProjectID,cast(StartOfMonth as date) from [Ispace]

)


SELECT distinct * from
(
select distinct
Proj.ESAProjectID,
Proj.Projectid,
GM.StartOfMonth as [Month],
isnull(TC.TicketOpen,0) as [Ticket opened] ,
isnull(TC.TicketClosenume,0) as [TicketClosenume],
isnull(TC.TicketClosedeno,0)as TicketClosedeno,
isnull(DTO.Debt_Open_Tickets,0) as Debt_Open_Tickets,
isnull(BT.BacklogTickets,0) as Backlog_Ticket,
cast (isnull(DTO.Debt_Open_Tickets,0) as float)+cast(isnull(BT.BacklogTickets,0) as float) as [Debt Tickets Open(+ 6 Months Backlog Tickets)],
isnull(DTC.DebtTicketClosed,0) as DebtTicketClosed,
'NA' as [Total Debt closure],
isnull(MR.MachineResolved,0)as MachineResolved,
isnull(MA.MachineAssisted,0)as MachineAssisted,
isnull(AR.AnalystResolved,0)as AnalystResolved,

isnull(I.OpportunitiesPushedtoispace,0)as OpportunitiesPushedtoispace,
isnull(DC.AvoidableTickets,0) as AvoidableTickets,
isnull(DC.AutomatableTickets,0) as [Automatable Tickets],
isnull(DC.AutoDebtClassification,0) as [Auto Debt Classification],
isnull(DC.ResidualTickets,0) as [Residual Tickets],
isnull(DC.Debt_deno,0) as Debt_deno,
isnull(DCT.Debt_ClosedTickets,0)as Debt_ClosedTickets 
from  AVL.MAS_ProjectMaster(NOLOCK)  Proj 
left join [Getlast24months] GM ON GM.ProjectID=Proj.ProjectID
left join [TicketCount] TC ON TC.Projectid=Proj.ProjectID and TC.StartOfMonth=GM.StartOfMonth
left Join [Debt_Tickets_ClosedColumns] DTC ON DTC.ProjectID=Proj.ProjectID and GM.StartOfMonth=DTC.StartOfMonth
left Join [DebtTicketsOpenedColumns] DTO ON DTO.ProjectID=Proj.ProjectID and DTO.StartOfMonth=GM.StartOfMonth
left Join [BacklogTickets] BT ON BT.ProjectID=Proj.ProjectID and BT.StartOfMonth=GM.StartOfMonth
left Join [MachineResolved] MR ON MR.ProjectID=Proj.ProjectID and MR.StartOfMonth=GM.StartOfMonth
left Join [MachineAssisted] MA ON MA.ProjectID=Proj.ProjectID and MA.StartOfMonth=GM.StartOfMonth
left Join [AnalystResolved] AR ON AR.ProjectID=Proj.ProjectID and AR.StartOfMonth=GM.StartOfMonth

left Join [Ispace] I ON I.ProjectID=Proj.ProjectID and I.StartOfMonth=GM.StartOfMonth
left Join [Debt_Columns] DC ON DC.ProjectID=Proj.ProjectID and DC.StartOfMonth=GM.StartOfMonth
left Join [Debt_ClosedTickets] DCT ON DCT.ProjectID=Proj.ProjectID and DCT.StartOfMonth=GM.StartOfMonth
WHERE Proj.Isdeleted=0 )as T
WHERE T.[Month] is not null
