
CREATE VIEW [dbo].[VW_TMUnClassifiedDebtTrend]  AS 
SELECT StartMonth, sum(EffortPrice) AS Price, count(1) AS Volume, sum(EffortTilldate) AS Effort, ProjectID, InscopeOutscope
FROM VW_TicketMasterClosedCompleted 
WHERE DebtClassificationName IS NULL
GROUP by StartMonth, ProjectID, InscopeOutscope
