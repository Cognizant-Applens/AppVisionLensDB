







--select * from [dbo].[VW_ApplensEffectivenessMetrics_KTilldate] where esaprojectid='1000363018'
CREATE view [dbo].[VW_ApplensEffectivenessMetrics_KTilldate]
AS
WITH [Ktickets](ProjectPatternMapID,ProjectID,KHealingTicketID,KTicketType,KDARTStatusID,KClosedMY,KOpenMY,KCancelMY)
As
(
SELECT HT.ProjectPatternMapID,ProjectID, Count(distinct HealingTicketID) as KHealingTicketID,TicketType as KTicketType,
DARTStatusID as KDARTStatusID, 
CASE WHEN DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.ClosedDate))<=DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())) then DATEADD(MINUTE, 30, DATEADD(HOUR, 5, HT.ClosedDate)) end as KClosedMY,
CASE WHEN DATEADD(MINUTE, 30, DATEADD(HOUR, 5, OpenDate))<=DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())) then DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5,OpenDate))), 0) end as KOpenMY,
CASE WHEN DATEADD(MINUTE, 30, DATEADD(HOUR, 5, CancellationDate))<=DATEADD(MINUTE,30,DATEADD(HOUR,5,GETDATE())) then DATEADD(month, DATEDIFF(month, 0, DATEADD(MINUTE, 30, DATEADD(HOUR, 5, CancellationDate))), 0) end as KCancelMY
from [$(DebtEngineDB)].DE.HealTicketDetails(NOLOCK)HT
inner join [$(DebtEngineDB)].DE.HealProjectPatternMappingDynamic(NOLOCK) PPD
ON PPD.ProjectPatternMapID=HT.ProjectPatternMapID
inner join [$(DebtEngineDB)].DE.HealParentChild (NOLOCK) HP ON HP.ProjectPatternMapID=PPD.ProjectPatternMapID
where TicketType='K' and HT.IsDeleted=0 and PPD.IsDeleted=0 and HP.IsDeleted=0 and HP.mapstatus=1
group by HT.ProjectPatternMapID,TicketType, HT.ClosedDate,DARTStatusID,HT.OpenDate,HT.CancellationDate,ProjectID
--DATEADD(month, DATEDIFF(month, 0, OpenDate), 0), DATEADD(month, DATEDIFF(month, 0, CancellationDate), 0)
),
[OpenKnowledgeTickets](ProjectID,[K Tickets (TD)])
AS
(
SELECT ProjectID, sum(KHealingTicketID) FROM [Ktickets]
where KDARTStatusID not in('5','8','7')
group by ProjectID
),
[ClosedKtickets](ProjectID,[K Tickets Closed (TD)])
AS
(
SELECT ProjectID, sum(KHealingTicketID) FROM [Ktickets]
where KDARTStatusID in('8')
group by ProjectID

),
[CancelledKtickets](ProjectID,[K Tickets Cancelled (TD)])
AS
(
SELECT ProjectID, sum(KHealingTicketID) FROM [Ktickets]
where KDARTStatusID in('5','7')
group by ProjectID
),
[TotalKAArticletemp](ProjectID,TotalKAArticle)
AS
(
select Pm.ProjectID as EsaProjectID,count(distinct KATicketID) as KArticles
from [AVL].[KEDB_TRN_KATicketDetails] KAT, avl.MAS_ProjectMaster PM 
where KAT.ProjectId = PM.ProjectID and KAT.isdeleted = 0
group by Pm.ProjectID
),
[TotalKAArticle](ProjectID,TotalKAArticle)
AS
(
select ProjectID as EsaProjectID,sum(TotalKAArticle)
from [TotalKAArticletemp]
group by ProjectID
)


SELECT * from(
SELECT Proj.ProjectID,
Proj.EsaProjectID,
isnull(OKT.[K Tickets (TD)],0)as [K Tickets (TD)],
isnull(CKT.[K Tickets Closed (TD)],0)as [K Tickets Closed (TD)],
isnull(CAKT.[K Tickets Cancelled (TD)],0)as [K Tickets Cancelled (TD)],
isnull(TKA.TotalKAArticle,0) as [K Articles Created (TD)]

from  AVL.MAS_ProjectMaster(NOLOCK)  Proj 
left  Join [OpenKnowledgeTickets] OKT ON OKT.ProjectID=Proj.ProjectID 
left  Join [ClosedKtickets] CKT ON CKT.ProjectID=Proj.ProjectID 
left  Join [CancelledKtickets] CAKT ON CAKT.ProjectID=Proj.ProjectID 
left  Join [TotalKAArticle]TKA ON TKA.ProjectID=Proj.ProjectID 
)
as T
--where T.[K Tickets (TD)]<>0 and 
--T.[K Tickets Closed (TD)]<>0 and 
--T.[K Tickets Cancelled (TD)] <>0  and
--T.[K Articles Created (TD)]<>0

