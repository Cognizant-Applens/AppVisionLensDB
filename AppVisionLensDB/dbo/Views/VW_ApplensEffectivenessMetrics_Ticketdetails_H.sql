








--select * from [dbo].[VW_ApplensEffectivenessMetrics_Ticketdetails_H] where esaprojectid='1000235334' and Month='2023-03-01'
CREATE view [dbo].[VW_ApplensEffectivenessMetrics_Ticketdetails_H]
AS
WITH [TicketDetailsBase](TicketID,ProjectID,DARTStatusID,EffortTilldate)
As
(
SELECT Count(TD.TicketID),TD.ProjectID,DARTStatusID,sum(EffortTilldate)
FROM AVL.TK_TRN_TicketDetail(NOLOCK) TD
where DATEADD(MINUTE, 30, DATEADD(HOUR, 5, OpenDateTime)) > DATEADD(year,-2,DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))) and TD.Isdeleted=0 and DARTStatusID!=13
group by ProjectID,DARTStatusID
union
SELECT Count(TD.TicketID),TD.ProjectID,DARTStatusID,sum(EffortTilldate)
FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) TD
where DATEADD(MINUTE, 30, DATEADD(HOUR, 5, OpenDateTime)) > DATEADD(year,-2,DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))) and TD.Isdeleted=0 and DARTStatusID!=13
group by ProjectID,DARTStatusID
),
[AHBase](ProjectID,HealingTicketID,TicketCount,TotalMonthlyIncidentReductionTillDate,TotalMonthlyEffortReductionTillDate,TicketType,
ReasonForCancellation,MarkAsDormant,DARTStatusID,AHCloseMY,AHOpenMY,AHCancelMY,AHCreateMY,DateMY)
AS
(
SELECT distinct PPD.ProjectID,HT.HealingTicketID,
Count(distinct HP.DARTTicketID) as TicketCount,
cast (Count(distinct HP.DARTTicketID) as float)/nullif(datediff(MONTH,nullif(DATEADD(MINUTE, 30, DATEADD(HOUR, 5, opendate)),0),DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))),0) as TotalMonthlyIncidentReductionTillDate,
(cast(sum(HP.EffortTilldate) as float)/cast (Count(distinct HP.DARTTicketID) as float))*
(cast (Count(HP.ID) as float)/nullif(datediff(MONTH,nullif(DATEADD(MINUTE, 30, DATEADD(HOUR, 5, opendate)),0),DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))),0)) as TotalMonthlyEffortReductionTillDate,
HT.TicketType ,ReasonForCancellation,MarkAsDormant,HT.DARTStatusID,
case when  DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.ClosedDate))<=DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())) then DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.ClosedDate))), 0)end AS AHCloseMY,
case when  DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.OpenDate))<=DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())) then DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5, OpenDate))), 0)end AS AHOpenMY,
case when  DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.CancellationDate))<=DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())) then DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.CancellationDate))), 0)end AS AHCancelMY,
case when  DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.CreatedDate))<=DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())) then DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.CreatedDate))), 0)end AS AHCreateMY,
case when HT.DARTStatusID=8 and DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.ClosedDate)) is not null then DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.ClosedDate))), 0)
when HT.DARTStatusID=5 and DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.CancellationDate)) is not null then DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.CancellationDate))), 0)
when HT.DARTStatusID=7  then DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.ModifiedDate))), 0) else DATEADD(month, DATEDIFF(month, 0, eomonth(DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())),+1)), 0)
end as DateMY FROM  [$(DebtEngineDB)].DE.HealTicketDetails(NOLOCK)HT
inner join [$(DebtEngineDB)].DE.HealProjectPatternMappingDynamic(NOLOCK) PPD
ON PPD.ProjectPatternMapID=HT.ProjectPatternMapID
inner join [$(DebtEngineDB)].DE.HealParentChild (NOLOCK) HP ON HP.ProjectPatternMapID=PPD.ProjectPatternMapID
--inner join [TicketDetailsBase] TD ON TD.ProjectID=PPD.ProjectID
where HT.TicketType='H' and HT.IsDeleted=0 and PPD.IsDeleted=0 and HP.IsDeleted=0 and HP.mapstatus=1
Group by PPD.ProjectID,HT.HealingTicketID, DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.ClosedDate)), DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.OpenDate)), DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.CancellationDate)),HT.DARTStatusID,HT.TicketType,
ReasonForCancellation,MarkAsDormant,DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.CreatedDate)),DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.ModifiedDate)),DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.opendate))

),
[AHOpenForMonth](ProjectID,AHOpenForMonth,ChildTicketsOpenForMonth,OpenMonthlyIncidentReductionForMonth,OpenMonthlyEffortReductionForMonth,TicketType,MONTH1)
As
(

SELECT  ProjectID,
Count(Distinct(HealingTicketID)) as AHOpenForMonth,
Sum(Ticketcount) as ChildTicketsOpenForMonth,
Sum(TotalMonthlyIncidentReductionTillDate) as OpenMonthlyIncidentReductionForMonth,
Sum(TotalMonthlyEffortReductionTillDate) as OpenMonthlyEffortReductionForMonth,
TicketType as Opened_TicketType  ,
AHOpenMY AS MONTH1
FROM [AHBase]
Group By projectid,
AHOpenMY,TicketType
),
[AHOpenForMonthColumns](ProjectID,[Created(CM)],[TicketsTaggedForCreated(CM)],[AvgIncidentReductionForCreated(CM)],[AvgEffortReductionForCreated(CM)],MONTH1)
AS
(
select ProjectID,
sum(AHOpenForMonth) as [Created(CM)],
sum(ChildTicketsOpenForMonth) as [TicketsTaggedForCreated(CM)],
sum(OpenMonthlyIncidentReductionForMonth) as [AvgIncidentReductionForCreated(CM)],
sum(OpenMonthlyEffortReductionForMonth) as [AvgEffortReductionForCreated(CM)],
MONTH1
from [AHOpenForMonth]
group by ProjectID,MONTH1
),
[AHClosedForMonth](ProjectID,AHClosedForMonth,ChildTicketsClosedForMonth,ClosedMonthlyIncidentReduction,ClosedMonthlyEffortReduction,ReasonForCancellation_Month,
Closed_TicketType,MarkAsDormant_Month,MONTH1)
As
(
SELECT ProjectID,
Count(DISTINCT HealingTicketID) as AHClosedForMonth,
Sum([TicketCount]) as ChildTicketsClosedForMonth,
Sum(TotalMonthlyIncidentReductionTillDate) as ClosedMonthlyIncidentReduction,
Sum(TotalMonthlyEffortReductionTillDate) as ClosedMonthlyEffortReduction,
ReasonForCancellation as ReasonForCancellation_Month,
TicketType as Closed_TicketType,
MarkAsDormant as MarkAsDormant_Month,
AHCloseMY AS MONTH1
FROM [AHBase]
Where DARTStatusID in('8')
Group By ProjectID , AHCloseMY ,
TicketType,ReasonForCancellation,MarkAsDormant
),
[AHClosedForMonthColumns](ProjectID,[Tickets Tagged For Closed (CM)],[Avg Incident Reduction For Closed (CM)],[Avg Effort Reduction For Closed (CM)],
[User Closed (CM)],[Tickets Tagged For User Closed (CM)],[Avg Effort Reduction For User Closed (CM)],[Avg Incident Reduction For User Closed (CM)],
[Closed],MONTH1)
As
(
SELECT ProjectID,
sum(ChildTicketsClosedForMonth) as [Tickets Tagged For Closed (CM)],
sum(ClosedMonthlyIncidentReduction) as [Avg Incident Reduction For Closed (CM)],
sum(ClosedMonthlyEffortReduction) as [Avg Effort Reduction For Closed (CM)],
(sum(AHClosedForMonth)-isnull(sum(case when MarkAsDormant_Month='1' and ReasonForCancellation_Month='Auto Closed due to Dormant' 
then (AHClosedForMonth)end),0))as [User Closed (CM)],
(sum(ChildTicketsClosedForMonth)-isnull(sum(case when MarkAsDormant_Month='1' and ReasonForCancellation_Month='Auto Closed due to Dormant' 
then (ChildTicketsClosedForMonth)end),0))as [Tickets Tagged For User Closed (CM)],
(sum(ClosedMonthlyEffortReduction)-isnull(sum(case when MarkAsDormant_Month='1' and ReasonForCancellation_Month='Auto Closed due to Dormant' 
then (ClosedMonthlyEffortReduction)end),0))as [Avg Effort Reduction For User Closed (CM)],
(sum(ClosedMonthlyIncidentReduction)-isnull(sum(case when MarkAsDormant_Month='1' and ReasonForCancellation_Month='Auto Closed due to Dormant' 
then (ClosedMonthlyIncidentReduction)end),0))as [Avg Incident Reduction For User Closed (CM)],
sum(AHClosedForMonth) as [Closed A],MONTH1
FROM [AHClosedForMonth]
group by ProjectID,MONTH1
),
[AHCancelledForMonth](ProjectID,AHCancelledForMonth,ChildTicketsCancelledForMonth,CancelledMonthlyIncidentReduction,CancelledMonthlyEffortReduction,
Cancelled_TicketType,MONTH1)
AS
(
SELECT ProjectID,
Count(DISTINCT HealingTicketID) as AHCancelledForMonth,
Sum([TicketCount]) as ChildTicketsCancelledForMonth,
Sum(TotalMonthlyIncidentReductionTillDate) as CancelledMonthlyIncidentReduction,
Sum(TotalMonthlyEffortReductionTillDate) as CancelledMonthlyEffortReduction,
TicketType as Cancelled_TicketType,
AHCancelMY AS MONTH1
FROM [AHBase] Where DARTStatusID in('5')
Group By ProjectID , AHCancelMY ,TicketType
),
[AHCancelledForMonthColumns](ProjectID,[Cancelled (CM)],[Tickets Tagged For Cancelled (CM)],
[Avg Incident Reduction For Cancelled (CM)],[Avg Effort Reduction For Cancelled (CM)],MONTH1)
AS
(
SELECT ProjectID,sum(AHCancelledForMonth) as [Cancelled (CM)],sum(ChildTicketsCancelledForMonth) as [Tickets Tagged For Cancelled (CM)],
sum(CancelledMonthlyIncidentReduction) as [Avg Incident Reduction For Cancelled (CM)],
sum(CancelledMonthlyEffortReduction) as [Avg Effort Reduction For Cancelled (CM)],MONTH1
FROM [AHCancelledForMonth] group by ProjectID,MONTH1
),
[TicketsTagged](ProjectID,TaggedChildTickets,MONTH1)
AS
(
SELECT ProjectID,sum(TicketCount),AHCloseMY from [AHBase]
group by ProjectID,AHCloseMY,TicketType
),
[GetLast24Months](Monthdate) 
 AS
(
    SELECT DATEADD(month, DATEDIFF(month, 0, eomonth(DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())),-23)), 0)   AS Monthdate
    UNION ALL
    SELECT DATEADD(MONTH, 1, Monthdate)
        FROM [GetLast24Months]
        WHERE ( DATEADD(MONTH, 1, Monthdate) <=  EOMONTH(DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())))) 
       
),
[ActiveASOn](ProjectID,Active,TicketType,DateMY,AHOpenMY)
As
(
SELECT Distinct ProjectID,
Count(Distinct(HealingTicketID)) as Active,
TicketType as ActiveTicketType,
DateMY,
AHOpenMY
FROM [AHBase]
Group By ProjectID,TicketType,DateMY,AHOpenMY
),
[ActiveASOnColumns](ProjectID,ActiveASOn,MONTH1)
As
(
SELECT distinct ProjectID,sum(Active) as ActiveASOn,G.Monthdate
FROM [ActiveASOn] A
left join [GetLast24Months] G ON A.AHOpenMY<=G.Monthdate and A.DateMY >G.Monthdate
Group by ProjectID,G.Monthdate
),
[DebtControl_Closed_ITD](ProjectID,AHCloseMY_ClosedITD,Closed_TicketType_ITD,TotalAHClosed_ITD,DormantClosed_ITD,
TotalClosedIncidentReduction_ITD,DormantClosedIncidentReduction_ITD)
AS
(
SELECT ProjectID,
AHCloseMY as AHCloseMY_ClosedITD,
TicketType as Closed_TicketType_ITD,
Count(DISTINCT HealingTicketID) as TotalAHClosed_ITD,
Count(DISTINCT case when ReasonForCancellation='Auto Closed due to Dormant'and MarkAsDormant='1'then HealingTicketID end) as DormantClosed_ITD,
Sum(TotalMonthlyIncidentReductionTillDate) as TotalClosedIncidentReduction_ITD,
Sum(case when ReasonForCancellation='Auto Closed due to Dormant'and MarkAsDormant='1' then TotalMonthlyIncidentReductionTillDate end) 
as DormantClosedIncidentReduction_ITD
FROM [AHBase] Where DARTStatusID in('8')
Group By ProjectID , AHCloseMY,TicketType
),
[DebtControl_Closed_ITDColumns_N](ProjectID,ATicketClosure_N,MONTH1)
AS
(
SELECT ProjectID,(isnull(SUM(CASE WHEN Closed_TicketType_ITD='H' then TotalAHClosed_ITD end),0)),G.Monthdate
FROM [DebtControl_Closed_ITD] DC
left join [GetLast24Months] G ON DC.AHCloseMY_ClosedITD<=G.Monthdate 
Group by ProjectID,G.Monthdate
),
[DebtControl_Cancelled_ITD](ProjectID,AHCancelMY_ITD,Cancelled_TicketTypeITD,TotalAHCancelled_ITD,TotalCancelledIncidentReduction_ITD)
AS
(
SELECT ProjectID,
AHCancelMY as AHCancelMY_ITD,
TicketType as Cancelled_TicketTypeITD,
Count(DISTINCT HealingTicketID) as TotalAHCancelled_ITD,
Sum(TotalMonthlyIncidentReductionTillDate) as TotalCancelledIncidentReduction_ITD
FROM [AHBase] Where DARTStatusID in('5')
Group By ProjectID , AHCancelMY,TicketType
),
[DebtControl_Cancelled_ITDColumns_N](ProjectID,ACancelled_ITD,MONTH1)
AS
(
SELECT ProjectID,(isnull(SUM(CASE WHEN Cancelled_TicketTypeITD='H' then TotalAHCancelled_ITD end),0)),G.Monthdate
FROM [DebtControl_Cancelled_ITD] DC
left join [GetLast24Months] G ON DC.AHCancelMY_ITD<=G.Monthdate 
Group by ProjectID,G.Monthdate

),
DormantClosed_ITD(ProjectID,DormantClosed_ITD,MONTH1)
AS
(
SELECT ProjectID,(isnull(SUM(CASE WHEN Closed_TicketType_ITD='H' then DormantClosed_ITD end),0)),G.Monthdate
FROM [DebtControl_Closed_ITD] DC
left join [GetLast24Months] G ON DC.AHCloseMY_ClosedITD<=G.Monthdate 
group by ProjectID,G.Monthdate
)
,
[DebtControl_Created_ITD](ProjectID,AHOpenMY_ITD,Created_TicketType,TotalAHCreated_ITD,TotalCreatedIncidentReduction_ITD)
AS
(
SELECT ProjectID,
AHOpenMY as AHOpenMY_ITD,
TicketType as Created_TicketType,
Count(DISTINCT HealingTicketID) as TotalAHCreated_ITD,
Sum(TotalMonthlyIncidentReductionTillDate) as TotalCreatedIncidentReduction_ITD
FROM [AHBase] 
Group By ProjectID ,AHOpenMY,TicketType
),
[DebtControl_Created_ITDColumns_N](ProjectID,ACreated_ITD,MONTH1)
AS
(
SELECT ProjectID,(isnull(SUM(CASE WHEN Created_TicketType='H' then TotalAHCreated_ITD end),0)),G.Monthdate
FROM [DebtControl_Created_ITD] DC
left join [GetLast24Months] G ON DC.AHOpenMY_ITD<=G.Monthdate 
Group by ProjectID,G.Monthdate
),
[AutomationEffectiveness_N](ProjectID,AutomationEffectiveness_N,MONTH1)
As
(
SELECT ProjectID,(isnull(SUM(CASE WHEN Closed_TicketType_ITD='H' then TotalClosedIncidentReduction_ITD end),0)),G.Monthdate
FROM [DebtControl_Closed_ITD] DC
left join [GetLast24Months] G ON DC.AHCloseMY_ClosedITD<=G.Monthdate 
Group by ProjectID,G.Monthdate
),
ADormantIncident_ITD(ProjectID,ADormantIncident_ITD,MONTH1)
As
(
SELECT ProjectID,(isnull(SUM(CASE WHEN Closed_TicketType_ITD='H' then DormantClosedIncidentReduction_ITD end),0)),G.Monthdate
FROM [DebtControl_Closed_ITD] DC
left join [GetLast24Months] G ON DC.AHCloseMY_ClosedITD<=G.Monthdate 
Group by ProjectID,G.Monthdate
),
ACancelled_IncidentReduction(ProjectID,ACancelled_IncidentReduction,MONTH1)
AS
(
SELECT ProjectID,(isnull(SUM(CASE WHEN Cancelled_TicketTypeITD='H' then TotalCancelledIncidentReduction_ITD end),0)),G.Monthdate
FROM [DebtControl_Cancelled_ITD] DC
left join [GetLast24Months] G ON DC.AHCancelMY_ITD<=G.Monthdate 
Group by ProjectID,G.Monthdate

),
ACreated_IncidentReduction(ProjectID,ACreated_IncidentReduction,MONTH1)
AS
(
SELECT ProjectID,(isnull(SUM(CASE WHEN Created_TicketType='H' then TotalCreatedIncidentReduction_ITD end),0)),G.Monthdate
FROM [DebtControl_Created_ITD] DC
left join [GetLast24Months] G ON DC.AHOpenMY_ITD<=G.Monthdate 
Group by ProjectID,G.Monthdate
),


[Getlast2yrsmonths](ProjectID,MONTH1)
AS
(
select distinct ProjectID,cast(MONTH1 as date) from [TicketsTagged] 
union 
select distinct ProjectID,cast(MONTH1 as date) from [AHOpenForMonthColumns]
union 
select distinct ProjectID,cast(MONTH1 as date) from [AHClosedForMonthColumns]
union
select distinct ProjectID,cast(MONTH1 as date) from [AHCancelledForMonthColumns] 
union
select distinct ProjectID,cast(MONTH1 as date) from [ActiveASOnColumns] 
union
select distinct ProjectID,cast(MONTH1 as date) from [DebtControl_Closed_ITDColumns_N] 
union
select distinct ProjectID,cast(MONTH1 as date) from [DebtControl_Cancelled_ITDColumns_N] 
union
select distinct ProjectID,cast(MONTH1 as date) from [DebtControl_Created_ITDColumns_N] 
union
select distinct ProjectID,cast(MONTH1 as date) from [AutomationEffectiveness_N]
union
select distinct ProjectID,cast(MONTH1 as date) from ACancelled_IncidentReduction 
union
select distinct ProjectID,cast(MONTH1 as date) from [ADormantIncident_ITD]
union
select distinct ProjectID,cast(MONTH1 as date) from ACreated_IncidentReduction
union 
select distinct ProjectID,cast(MONTH1 as date) from DormantClosed_ITD

)

SELECT * from 
(SELECT Proj.ProjectID,
Proj.EsaProjectID,
GM.MONTH1 as [Month],
isnull([Created(CM)],0) as 'Created(CM)_H',
isnull([TicketsTaggedForCreated(CM)],0) as 'Tickets Tagged For Created(CM)_H',
isnull([AvgIncidentReductionForCreated(CM)],0) as 'Avg Incident Reduction For Created(CM)_H',
isnull([AvgEffortReductionForCreated(CM)],0) as 'Avg Effort Reduction For Created(CM)_H',
isnull([Tickets Tagged For Closed (CM)],0) as [Tickets Tagged For Closed (CM)_H],
isnull([Avg Incident Reduction For Closed (CM)],0)as [Avg Incident Reduction For Closed (CM)_H],
isnull([Avg Effort Reduction For Closed (CM)],0) as [Avg Effort Reduction For Closed (CM)_H],
isnull([User Closed (CM)],0)as [User Closed (CM)_H],
isnull([Tickets Tagged For User Closed (CM)],0) as [Tickets Tagged For User Closed (CM)_H],
isnull([Avg Effort Reduction For User Closed (CM)] ,0)as [Avg Effort Reduction For User Closed (CM)_H],
isnull([Avg Incident Reduction For User Closed (CM)],0) as [Avg Incident Reduction For User Closed (CM)_H],
isnull([Closed],0) as [Closed_H],
isnull([Cancelled (CM)],0) as [Cancelled (CM)_H],
isnull([Tickets Tagged For Cancelled (CM)],0) as [Tickets Tagged For Cancelled (CM)_H],
isnull([Avg Incident Reduction For Cancelled (CM)],0) as [Avg Incident Reduction For Cancelled (CM)_H],
isnull([Avg Effort Reduction For Cancelled (CM)],0) as [Avg Effort Reduction For Cancelled (CM)_H],
isnull(TaggedChildTickets,0) as [Tickets Tagged to_H],
isnull(ActiveASOn,0) as [Active A As On (CM)_H],
(isnull(DCl.ATicketClosure_N,0)-isnull(DOCL.DormantClosed_ITD,0)) as HTicketClosure_N,
(isnull(DCR.ACreated_ITD,0)-isnull(DCA.ACancelled_ITD,0)-isnull(DOCL.DormantClosed_ITD,0)) as HTicketClosure_D,
isnull(AutomationEffectiveness_N,0)-isnull(ADormantIncident_ITD,0) as HealingEffectiveness_N,
(isnull(ACreated_IncidentReduction,0)-isnull(ACancelled_IncidentReduction,0)-isnull(ADormantIncident_ITD,0)) as HealingEffectiveness_D



--CASE WHEN TT.MONTH1 is not null then TT.MONTH1 WHEN AHO.MONTH1 is not null then AHO.MONTH1 WHEN AHC.MONTH1 is not null then AHC.MONTH1 
--WHEN AAOC.MONTH1 is not null then AAOC.MONTH1
--else AHCa.MONTH1 end as [Month]
from  AVL.MAS_ProjectMaster(NOLOCK)  Proj 
left join [Getlast2yrsmonths] GM ON GM.ProjectID=Proj.ProjectID 
left join [TicketsTagged] TT ON TT.ProjectID=Proj.ProjectID  and  GM.MONTH1=TT.MONTH1
left join [AHOpenForMonthColumns] AHO ON AHO.ProjectID=Proj.ProjectID and GM.MONTH1=AHO.MONTH1
left join [AHClosedForMonthColumns] AHC ON AHC.ProjectID=Proj.ProjectID and AHC.MONTH1=GM.MONTH1
left join [AHCancelledForMonthColumns] AHCa ON AHCa.ProjectID=Proj.ProjectID and AHCa.MONTH1=GM.MONTH1
left join [ActiveASOnColumns] AAOC ON AAOC.ProjectID=Proj.ProjectID and AAOC.MONTH1=GM.MONTH1
left join [DebtControl_Closed_ITDColumns_N] DCl ON DCl.ProjectID=Proj.ProjectID and DCl.MONTH1=GM.MONTH1
left join DormantClosed_ITD  DOCl ON DOCl.ProjectID=Proj.ProjectID and DOCl.MONTH1=GM.MONTH1
left join [DebtControl_Cancelled_ITDColumns_N] DCA ON DCA.ProjectID=Proj.ProjectID and DCA.MONTH1=GM.MONTH1
left join [DebtControl_Created_ITDColumns_N] DCR ON DCR.ProjectID=Proj.ProjectID and DCR.MONTH1=GM.MONTH1
left join [AutomationEffectiveness_N] AEN ON AEN.ProjectID=Proj.ProjectID and AEN.MONTH1=GM.MONTH1
left join ADormantIncident_ITD ADI ON ADI.ProjectID=Proj.ProjectID and ADI.MONTH1=GM.MONTH1
left join ACreated_IncidentReduction ACRI ON ACRI.ProjectID=Proj.ProjectID and ACRI.MONTH1=GM.MONTH1
left join ACancelled_IncidentReduction ACA ON ACA.ProjectID=Proj.ProjectID and ACA.MONTH1=GM.MONTH1

)as T
where T.[Month] is not null
