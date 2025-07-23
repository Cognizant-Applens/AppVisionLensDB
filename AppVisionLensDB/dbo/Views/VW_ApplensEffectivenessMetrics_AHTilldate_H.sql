









--select * from [dbo].[VW_ApplensEffectivenessMetrics_AHTilldate_H] where projectid='19158'
CREATE view [dbo].[VW_ApplensEffectivenessMetrics_AHTilldate_H]
AS
WITH [TicketDetailsBase](TicketID,ProjectID,DARTStatusID,EffortTilldate)
As
(
SELECT Count(TD.TicketID),TD.ProjectID,DARTStatusID,sum(EffortTilldate)
FROM AVL.TK_TRN_TicketDetail(NOLOCK) TD
where  DATEADD(MINUTE, 30, DATEADD(HOUR, 5, OpenDateTime)) > DATEADD(year,-2,DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))) and TD.Isdeleted=0 and DARTStatusID!=13
group by ProjectID,DARTStatusID
union
SELECT Count(TD.TicketID),TD.ProjectID,DARTStatusID,sum(EffortTilldate)
FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) TD
where DATEADD(MINUTE, 30, DATEADD(HOUR, 5, OpenDateTime)) > DATEADD(year,-2,DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))) and TD.Isdeleted=0 and DARTStatusID!=13
group by ProjectID,DARTStatusID
),
[AHBase](ProjectID,HealingTicketID,TicketCount,TotalMonthlyIncidentReductionTillDate,TotalMonthlyEffortReductionTillDate,TicketType,
ReasonForCancellation,MarkAsDormant,DARTStatusID)
AS
(
SELECT distinct PPD.ProjectID,HT.HealingTicketID,
Count(distinct HP.DARTTicketID) as TicketCount,
cast (Count(distinct HP.DARTTicketID) as float)/nullif(datediff(MONTH,nullif(DATEADD(MINUTE, 30, DATEADD(HOUR, 5, opendate)),0),DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE()))),0) as TotalMonthlyIncidentReductionTillDate,
(cast(sum(HP.EffortTilldate) as float)/cast (Count(distinct HP.DARTTicketID) as float))*
(cast (Count(HP.ID) as float)/nullif(datediff(MONTH,nullif(DATEADD(MINUTE, 30, DATEADD(HOUR, 5, opendate)),0),getdate()),0)) as TotalMonthlyEffortReductionTillDate,
HT.TicketType ,
ReasonForCancellation,MarkAsDormant,HT.DARTStatusID
 FROM  [$(DebtEngineDB)].DE.HealTicketDetails(NOLOCK)HT
inner join [$(DebtEngineDB)].DE.HealProjectPatternMappingDynamic(NOLOCK) PPD
ON PPD.ProjectPatternMapID=HT.ProjectPatternMapID
inner join [$(DebtEngineDB)].DE.HealParentChild (NOLOCK) HP ON HP.ProjectPatternMapID=PPD.ProjectPatternMapID
--inner join [TicketDetailsBase] TD ON TD.ProjectID=PPD.ProjectID
where HT.TicketType='H' and HT.IsDeleted=0 and PPD.IsDeleted=0 and HP.IsDeleted=0 and HP.mapstatus=1
Group by PPD.ProjectID,HT.HealingTicketID,HT.DARTStatusID,HT.TicketType,
ReasonForCancellation,MarkAsDormant,DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.opendate))
),
[AHTillDate](ProjectID,TotalAHTillDate,TotalChildTicketsTillDate,TotalMonthlyIncidentReductionTillDate,TotalMonthlyEffortReductionTillDate,TicketType,
ReasonForCancellation,MarkAsDormant,DARTStatusID)
AS
(
SELECT HT.ProjectID,Count(distinct HT.HealingTicketID),
sum(TicketCount)as TotalChildTicketsTillDate,
sum(TotalMonthlyIncidentReductionTillDate) as TotalMonthlyIncidentReductionTillDate,
sum(TotalMonthlyEffortReductionTillDate) as TotalMonthlyEffortReductionTillDate,HT.TicketType ,
ReasonForCancellation,MarkAsDormant,HT.DARTStatusID FROM [AHBase]HT
Group by HT.ProjectID,HT.TicketType,ReasonForCancellation,MarkAsDormant,HT.DARTStatusID
),
[AHTillDateColumns](ProjectID,[ActiveH],[TicketsTaggedForActiveH],
[AvgIncidentReductionForActiveH],[AvgEffortReductionForActiveH],[CreatedH],[TicketsTaggedForCreatedH],[AvgIncidentReductionForCreatedH],
[AvgEffortReductionForCreatedH],[ClosedH],[TicketsTaggedForClosedH],[AvgIncidentReductionForClosedH],[AvgEffortReductionForClosedH],[UserClosedH],
[TicketsTaggedForUserClosedH],[AvgIncidentReductionForUserClosedH],[AvgEffortReductionForUserClosedH],[CancelledH],[TicketsTaggedForCancelledH],
[AvgIncidentReductionForCancelledH],[AvgEffortReductionForCancelledH])
AS
(
SELECT ProjectID, 
sum(case when TicketType='H' and DARTStatusID  not in('5','7','8')then (TotalAHTillDate)end) as [ActiveH], --Fix
sum(case when TicketType='H' and DARTStatusID  not in('5','7','8')then (TotalChildTicketsTillDate)end) as [TicketsTaggedForActiveH],
sum(case when TicketType='H' and DARTStatusID  not in('5','7','8')then (TotalMonthlyIncidentReductionTillDate)end) as [AvgIncidentReductionForActiveH],
sum(case when TicketType='H' and DARTStatusID  not in('5','7','8')then (TotalMonthlyEffortReductionTillDate)end) as [AvgEffortReductionForActiveH],
sum(CASE when TicketType='H' then (TotalAHTillDate) end )as [CreatedH],
sum(CASE when TicketType='H' then (TotalChildTicketsTillDate) end) as [TicketsTaggedForCreatedH],
sum(CASE when TicketType='H' then (TotalMonthlyIncidentReductionTillDate) end) as [AvgIncidentReductionForCreatedH],
sum(CASE when TicketType='H' then (TotalMonthlyEffortReductionTillDate) end) as [AvgEffortReductionForCreatedH],
sum(case when TicketType='H' and DARTStatusID  in('8')then (TotalAHTillDate)end) as [ClosedH],
sum(case when TicketType='H' and DARTStatusID  in('8')then (TotalChildTicketsTillDate)end )as [TicketsTaggedForClosedH],
sum(case when TicketType='H' and DARTStatusID  in('8')then (TotalMonthlyIncidentReductionTillDate)end) as [AvgIncidentReductionForClosedH],
sum(case when TicketType='H' and DARTStatusID  in('8')then (TotalMonthlyEffortReductionTillDate)end) as [AvgEffortReductionForClosedH],
(sum(case when TicketType='H' and DARTStatusID  in('8')then (TotalAHTillDate)end)-isnull(sum(case when TicketType='H' and DARTStatusID  in('8') and 
MarkAsDormant in('1') and ReasonForCancellation in('Auto Closed due to Dormant') then (TotalAHTillDate)end),0))as [UserClosedH] ,
(sum(case when TicketType='H' and DARTStatusID  in('8')then (TotalChildTicketsTillDate)end)-isnull(sum(case when TicketType='H' and DARTStatusID  in('8') and 
MarkAsDormant in('1') and ReasonForCancellation in('Auto Closed due to Dormant') then (TotalChildTicketsTillDate)end),0))as [TicketsTaggedForUserClosedH],
(sum(case when TicketType='H' and DARTStatusID  in('8')then (TotalMonthlyIncidentReductionTillDate)end)-isnull(sum(case when TicketType='H' and DARTStatusID  in('8') and 
MarkAsDormant in('1') and ReasonForCancellation in('Auto Closed due to Dormant') then (TotalMonthlyIncidentReductionTillDate)end),0))
as [AvgIncidentReductionForUserClosedH],
(sum(case when TicketType='H' and DARTStatusID  in('8')then (TotalMonthlyEffortReductionTillDate)end)-isnull(sum(case when TicketType='H' and DARTStatusID  in('8') and 
MarkAsDormant in('1') and ReasonForCancellation in('Auto Closed due to Dormant') then (TotalMonthlyEffortReductionTillDate)end),0))
as [AvgEffortReductionForUserClosedH],
sum(case when TicketType='H' and DARTStatusID  in('5')then (TotalAHTillDate)end) as [CancelledH],
sum(case when TicketType='H' and DARTStatusID  in('5')then (TotalChildTicketsTillDate)end) as [TicketsTaggedForCancelledH],
sum(case when TicketType='H' and DARTStatusID  in('5')then (TotalMonthlyIncidentReductionTillDate)end )as [AvgIncidentReductionForCancelledH],
sum(case when TicketType='H' and DARTStatusID  in('5')then (TotalMonthlyEffortReductionTillDate)end) as [AvgEffortReductionForCancelledH]

From [AHTillDate]
group by ProjectID
)
SELECT * from
(SELECT Proj.ProjectID,
Proj.EsaProjectID,
isnull([ActiveH],0) as 'Active',
isnull([TicketsTaggedForActiveH],0) as 'Tickets Tagged For Active',
isnull([AvgIncidentReductionForActiveH],0) as 'Avg Incident Reduction For Active',
isnull([AvgEffortReductionForActiveH],0) as 'Avg Effort Reduction ForActive',
isnull([AvgIncidentReductionForCreatedH],0) as 'Avg Incident Reduction For Created',
isnull([CreatedH],0) as 'Created',
isnull([TicketsTaggedForCreatedH],0) as 'Tickets Tagged For Created',
isnull([AvgEffortReductionForCreatedH],0) as 'Avg Effort Reduction For Created',
isnull([ClosedH],0) as 'Closed',
isnull([TicketsTaggedForClosedH],0) as 'Tickets Tagged For Closed',
isnull([AvgEffortReductionForClosedH],0) as 'Avg Effort Reduction For Closed',
isnull([AvgIncidentReductionForClosedH],0) as 'Avg Incident Reduction For Closed',
isnull([UserClosedH],0) as 'User Closed',
isnull([TicketsTaggedForUserClosedH],0) as 'Tickets Tagged For User Closed',
isnull([AvgIncidentReductionForUserClosedH],0) as 'Avg Incident Reduction For User Closed',
isnull([AvgEffortReductionForUserClosedH],0) as 'Avg Effort Reduction For User Closed',
isnull([CancelledH],0) as 'Cancelled',
isnull([TicketsTaggedForCancelledH],0) as 'Tickets Tagged For Cancelled',
isnull([AvgIncidentReductionForCancelledH],0) as 'Avg Incident Reduction For Cancelled',
isnull([AvgEffortReductionForCancelledH],0) as 'Avg Effort Reduction For Cancelled'
from  AVL.MAS_ProjectMaster(NOLOCK)  Proj 
left join [AHTillDateColumns] AHCol ON AHCol.ProjectID=Proj.ProjectID)
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
--T.[Closed]<>0 and 
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
--T.[Avg Effort Reduction For Cancelled] <>0  
