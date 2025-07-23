--select * from [dbo].[VW_ApplensEffectivenessMetrics_A
CREATE view [dbo].[VW_ApplensEffectivenessMetrics_AHTilldate_A]
AS
WITH [TicketDetailsBase](TicketID,ProjectID,DARTStatusID,EffortTilldate)
As
(
SELECT (TD.TicketID),TD.ProjectID,DARTStatusID,sum(EffortTilldate)
FROM AVL.TK_TRN_TicketDetail(NOLOCK) TD
where DATEADD(MINUTE, 30, DATEADD(HOUR, 5, OpenDateTime)) 
> DATEADD(year,-2,DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))) and TD.Isdeleted=0 and DARTStatusID!=13
group by ProjectID,DARTStatusID,TicketID
--union
--SELECT Count(TD.TicketID),TD.ProjectID,DARTStatusID,sum(EffortTilldate)
--FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) TD
--where OpenDateTime > DATEADD(year,-2,GETDATE()) and TD.Isdeleted=0 and DARTStatusID!=13
--group by ProjectID,DARTStatusID
),
[AHBase](ProjectID,HealingTicketID,TicketCount,TotalMonthlyIncidentReductionTillDate,TotalMonthlyEffortReductionTillDate,TicketType,
ReasonForCancellation,MarkAsDormant,DARTStatusID)
AS
(
SELECT distinct PPD.ProjectID,HT.HealingTicketID,
Count(distinct HP.DARTTicketID) as TicketCount,
case when (((year(DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())))*12)+month(DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))))-((year(DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.OpenDate)))*12)+month(DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.OpenDate)))))=0 then 0 else
cast (Count( HP.DARTTicketID) as float)/(((year(DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())))*12)+month(DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))))-((year(DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.OpenDate)))*12)+month(DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.OpenDate)))))end
as TotalMonthlyIncidentReductionTillDate,
sum(CASE WHEN HT.ManualNonDebt=1 then (EffortReductionMonth)
WHEN HT.ManualNonDebt=0 then  cast ((HP.EffortTilldate) as float)/nullif(datediff(MONTH,nullif(DATEADD(MINUTE, 30, DATEADD(HOUR, 5, opendate)),0),DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))),0) end) as TotalMonthlyEffortReductionTillDate,
HT.TicketType,ReasonForCancellation,MarkAsDormant,HT.DARTStatusID
 FROM  [$(DebtEngineDB)].DE.HealTicketDetails(NOLOCK)HT
inner join [$(DebtEngineDB)].DE.HealProjectPatternMappingDynamic(NOLOCK) PPD
ON PPD.ProjectPatternMapID=HT.ProjectPatternMapID
inner join [$(DebtEngineDB)].DE.HealParentChild (NOLOCK) HP ON HP.ProjectPatternMapID=PPD.ProjectPatternMapID
--inner join [TicketDetailsBase] TD ON TD.ProjectID=PPD.ProjectID and TD.TicketID=HP.DARTTicketID
where HT.TicketType='A' and HT.IsDeleted=0 and PPD.IsDeleted=0 and HP.IsDeleted=0 and HP.mapstatus=1
Group by PPD.ProjectID,HT.HealingTicketID,HT.DARTStatusID,HT.TicketType,
ReasonForCancellation,MarkAsDormant,DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.opendate))--,HT.ManualNonDebt,EffortReductionMonth
--,HT.ManualNonDebt,HP.EffortTilldate
),
[AHTillDate](ProjectID,TotalAHTillDate,TotalChildTicketsTillDate,TotalMonthlyIncidentReductionTillDate,TotalMonthlyEffortReductionTillDate,TicketType,
ReasonForCancellation,MarkAsDormant,DARTStatusID)
AS
(
SELECT HT.ProjectID,Count(distinct HT.HealingTicketID),
sum (TicketCount)as TotalChildTicketsTillDate,
sum(TotalMonthlyIncidentReductionTillDate) as TotalMonthlyIncidentReductionTillDate,
sum(TotalMonthlyEffortReductionTillDate) as TotalMonthlyEffortReductionTillDate,HT.TicketType ,
ReasonForCancellation,MarkAsDormant,HT.DARTStatusID FROM [AHBase]HT
Group by HT.ProjectID,HT.TicketType,ReasonForCancellation,MarkAsDormant,HT.DARTStatusID
),
[AHTillDateColumns](ProjectID,[ActiveA],[TicketsTaggedForActiveA],[AvgIncidentReductionForActiveA],[AvgEffortReductionForActiveA],[AvgIncidentReductionForCreatedA],
[CreatedA],[TicketsTaggedForCreatedA],[AvgEffortReductionForCreatedA],[ClosedA],[TicketsTaggedForClosedA],[AvgEffortReductionForClosedA],
[AvgIncidentReductionForClosedA],
[UserClosedA],[TicketsTaggedForUserClosedA],[AvgIncidentReductionForUserClosedA],[AvgEffortReductionForUserClosedA],
[CancelledA],[TicketsTaggedForCancelledA],[AvgIncidentReductionForCancelledA],[AvgEffortReductionForCancelledA])
AS
(
SELECT ProjectID, sum(case when TicketType='A' and DARTStatusID not in('5','7','8') then (TotalAHTillDate) end) as [ActiveA],
sum(CASE WHEN  TicketType='A' and DARTStatusID not in('5','7','8') then (TotalChildTicketsTillDate) end) as [TicketsTaggedForActiveA],
sum(CASE WHEN  TicketType='A' and DARTStatusID not in('5','7','8') then (TotalMonthlyIncidentReductionTillDate) end )as [AvgIncidentReductionForActiveA],
sum(CASE WHEN  TicketType='A' and DARTStatusID not in('5','7','8') then (TotalMonthlyEffortReductionTillDate) end )as [AvgEffortReductionForActiveA],
sum(CASE WHEN TicketType='A' then (TotalMonthlyIncidentReductionTillDate) end) as [AvgIncidentReductionForCreatedA],
sum(CASE when TicketType='A' then (TotalAHTillDate) end) as [CreatedA],
sum(CASE WHEN  TicketType='A' then (TotalChildTicketsTillDate) end )as [TicketsTaggedForCreatedA],
sum(CASE WHEN  TicketType='A' then (TotalMonthlyEffortReductionTillDate) end) as [AvgEffortReductionForCreatedA],
sum(case when TicketType='A' and DARTStatusID  in('8')then (TotalAHTillDate)end )as [ClosedA],
sum(case when TicketType='A' and DARTStatusID  in('8')then (TotalChildTicketsTillDate)end) as [TicketsTaggedForClosedA],
sum(case when TicketType='A' and DARTStatusID  in('8')then (TotalMonthlyEffortReductionTillDate)end )as [AvgEffortReductionForClosedA],
sum(case when TicketType='A' and DARTStatusID  in('8')then (TotalMonthlyIncidentReductionTillDate)end) as [AvgIncidentReductionForClosedA],
(sum(case when TicketType='A' and DARTStatusID  in('8')then (TotalAHTillDate)end))-isnull(sum(case when TicketType='A' and DARTStatusID  in('8') and 
MarkAsDormant in('1') and ReasonForCancellation in('Auto Closed due to Dormant') then (TotalAHTillDate)end),0)as [UserClosedA],
(sum(case when TicketType='A' and DARTStatusID  in('8')then (TotalChildTicketsTillDate)end)-isnull(sum(case when TicketType='A' and DARTStatusID  in('8') and 
MarkAsDormant in('1') and ReasonForCancellation in('Auto Closed due to Dormant') then (TotalChildTicketsTillDate)end),0))as [TicketsTaggedForUserClosedA],
(sum(case when TicketType='A' and DARTStatusID  in('8')then (TotalMonthlyIncidentReductionTillDate)end)-isnull(sum(case when TicketType='A' and DARTStatusID  in('8') and 
MarkAsDormant in('1') and ReasonForCancellation in('Auto Closed due to Dormant') then (TotalMonthlyIncidentReductionTillDate)end),0))
as [AvgIncidentReductionForUserClosedA],
(sum(case when TicketType='A' and DARTStatusID  in('8')then (TotalMonthlyEffortReductionTillDate)end)-isnull(sum(case when TicketType='A' and DARTStatusID  in('8') and 
MarkAsDormant in('1') and ReasonForCancellation in('Auto Closed due to Dormant') then (TotalMonthlyEffortReductionTillDate)end),0))
as [AvgEffortReductionForUserClosedA],
sum(case when TicketType='A' and DARTStatusID  in('5')then (TotalAHTillDate)end) as [CancelledA],
sum(case when TicketType='A' and DARTStatusID  in('5')then (TotalChildTicketsTillDate)end) as [TicketsTaggedForCancelledA],
sum(case when TicketType='A' and DARTStatusID  in('5')then (TotalMonthlyIncidentReductionTillDate)end) as [AvgIncidentReductionForCancelledA],
sum(case when TicketType='A' and DARTStatusID  in('5')then (TotalMonthlyEffortReductionTillDate)end )as [AvgEffortReductionForCancelledA]
From [AHTillDate]
group by ProjectID
)

SELECT * from(
SELECT Proj.ProjectID,
Proj.EsaProjectID,
isnull([ActiveA],0) as 'Active',
isnull([TicketsTaggedForActiveA],0) as 'Tickets Tagged For Active',
isnull([AvgIncidentReductionForActiveA],0) as 'Avg Incident Reduction For Active',
isnull([AvgEffortReductionForActiveA],0) as 'Avg Effort Reduction ForActive',
isnull([AvgIncidentReductionForCreatedA],0) as 'Avg Incident Reduction For Created',
isnull([CreatedA],0) as 'Created',
isnull([TicketsTaggedForCreatedA],0) as 'Tickets Tagged For Created',
isnull([AvgEffortReductionForCreatedA],0) as 'Avg Effort Reduction For Created',
isnull([ClosedA],0) as 'Closed_Tilldate',
isnull([TicketsTaggedForClosedA],0) as 'Tickets Tagged For Closed',
isnull([AvgEffortReductionForClosedA],0) as 'Avg Effort Reduction For Closed',
isnull([AvgIncidentReductionForClosedA],0) as 'Avg Incident Reduction For Closed',
isnull([UserClosedA],0) as 'User Closed',
isnull([TicketsTaggedForUserClosedA],0) as 'Tickets Tagged For User Closed',
isnull([AvgIncidentReductionForUserClosedA],0) as 'Avg Incident Reduction For User Closed',
isnull([AvgEffortReductionForUserClosedA],0) as 'Avg Effort Reduction For User Closed',
isnull([CancelledA],0) as 'Cancelled',
isnull([TicketsTaggedForCancelledA],0) as 'Tickets Tagged For Cancelled',
isnull([AvgIncidentReductionForCancelledA],0) as 'Avg Incident Reduction For Cancelled',
isnull([AvgEffortReductionForCancelledA],0) as 'Avg Effort Reduction For Cancelled'

from  AVL.MAS_ProjectMaster(NOLOCK)  Proj 
left join [AHTillDateColumns] AHCol ON AHCol.ProjectID=Proj.ProjectID
)
as T
--where T.Cancelled <>0 or T.ProjectID <>0 and
--T.Active <>0 and
--T.[Tickets Tagged For Active] <>0 and 
--T.[Avg Incident Reduction For Active] <>0 and 
--T.[Avg Effort Reduction ForActive] <>0 and 
--T.[Avg Incident Reduction For Created] <>0 and 
--T.[Created]<>0 and 
--T.[Tickets Tagged For Created]<>0 and 
--T.[Avg Effort Reduction For Created]<>0 and 
--T.[Closed_Tilldate]<>0 and 
--T.[Tickets Tagged For Closed]<>0 and 
--T.[Avg Effort Reduction For Closed] <>0 and 
--T.[Avg Incident Reduction For Closed]<>0 and 
--T.[User Closed]<>0 and 
--T.[Tickets Tagged For User Closed] <>0 and 
--T.[Avg Incident Reduction For User Closed]<>0 and 
--T.[Avg Effort Reduction For User Closed]<>0 and 
--T.[Cancelled]<>0 and 
--T.[Tickets Tagged For Cancelled]<>0 and 
--T.[Avg Incident Reduction For Cancelled]<>0 and 
--T.[Avg Effort Reduction For Cancelled] <>0  and
--T.[K Tickets (TD)]<>0 and 
--T.[K Tickets Closed (TD)]<>0 and 
--T.[K Tickets Cancelled (TD)] <>0  and
--T.[K Articles Created (TD)]<>0

