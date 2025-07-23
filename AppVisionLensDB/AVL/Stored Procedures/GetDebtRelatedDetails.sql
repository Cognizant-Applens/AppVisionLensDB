-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE AVL.GetDebtRelatedDetails
AS
BEGIN  
 BEGIN TRY  
 SET NOCOUNT ON  
 
DECLARE @ToDate DATETIME=GETDATE()
DECLARE @FromDate  DATETIME=DATEADD(YEAR,-2,GETDATE())

SELECT  
TD.TicketID AS [Ticket Number],
TD.ApplicationID AS [Application  ID/Tower ID] ,
ApplicationName AS [Application Name/Tower Name],TD.TicketCreateDate AS [Ticket Created On],
MPM.PriorityName AS [Priority],
TD.EffortTillDate AS [Efforts],
--'NEED TO UPDATE' AS [Ticket Resolution Date],
DC.DebtClassificationName AS [Debt Classification Name],
RD.ResidualDebtName AS [Residual Debt Name],
AF.AvoidableFlagName AS [Avoidable Flag Name],
--'NEED TO UPDATE' AS [Task Type],
AGM.AssignmentGroupName AS [Assignment Group],
TD.ResolutionRemarks AS [Resolution Notes],
TD.TimeTickerID AS [Time Ticker ID],
C.CustomerName AS [Customer Name],
BU.BUName AS [BU Name],
PT.PrimaryTechnologyName AS [Technology Name],
CC.CauseCode AS [Cause Code],
RC.ResolutionCode AS [Resolution Code],
DTS.DARTStatusName AS [Ticket Status],
MS.ServiceName AS [Service],
TD.ClosedDate AS [Closed Date],
DDC.DebtClassificationName AS [Debt Classification Mode],
PM.ProjectId AS [Project ID ],
PM.ProjectName AS [Project Name],
'APP' AS[TicketType]
FROM [AVL].[TK_TRN_TicketDetail](NOLOCK) TD 
INNER JOIN AVL.APP_MAS_ApplicationDetails(NOLOCK) AD ON TD.ApplicationID=AD.ApplicationID AND (TD.IsDeleted=0 OR TD.IsDeleted IS NULL) AND  (AD.IsActive=1)
INNER JOIN AVL.TK_MAP_PriorityMapping(NOLOCK) MPM ON TD.PriorityMapID=MPM.PriorityIDMapID AND (MPM.IsDeleted=0 OR MPM.IsDeleted IS NULL) 
INNER JOIN AVL.DEBT_MAS_DebtClassification(NOLOCK) DC ON TD.DebtClassificationMapID=DC.DebtClassificationID AND (DC.IsDeleted=0 OR DC.IsDeleted IS NULL) 
INNER JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RD ON TD.ResidualDebtMapID = RD.ResidualDebtID AND (RD.IsDeleted=0 OR RD.IsDeleted IS NULL)
INNER JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AF ON TD.AvoidableFlag=AF.AvoidableFlagID AND (AF.IsDeleted=0 OR AF.IsDeleted IS NULL)
INNER JOIN AVL.BOTAssignmentGroupMapping(NOLOCK) AGM ON TD.AssignmentGroupID= AGM.AssignmentGroupMapID AND (AGM.IsDeleted=0 OR AGM.IsDeleted IS NULL)
INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.Projectid=TD.ProjectId AND (PM.IsDeleted=0 OR PM.IsDeleted IS NULL)
INNER JOIN AVL.Customer(NOLOCK) C ON C.CustomerID=PM.CustomerID AND (C.IsDeleted=0 OR C.IsDeleted IS NULL)
INNER JOIN AVL.BusinessUnit(NOLOCK) BU ON BU.BUID=C.BUID AND (BU.IsDeleted=0 OR BU.IsDeleted IS NULL)
INNER JOIN AVL.APP_MAS_PrimaryTechnology(NOLOCK)  PT ON PT.PrimaryTechnologyID=AD.PrimaryTechnologyID AND (PT.IsDeleted=0 OR PT.IsDeleted IS NULL)
INNER JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON TD.CausecodeMapID=CC.CauseID AND (CC.IsDeleted=0 OR CC.IsDeleted IS NULL)
INNER JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RC ON TD.ResolutioncodeMapID=RC.ResolutionID AND (RC.IsDeleted=0 OR RC.IsDeleted IS NULL)
INNER JOIN AVL.TK_MAS_DARTTicketStatus(NOLOCK) DTS ON TD.DARTStatusID=DTS.DARTStatusID AND DTS.IsDeleted=0 AND (DTS.IsDeleted=0 OR DTS.IsDeleted IS NULL)
INNER JOIN AVL.TK_MAS_Service(NOLOCK) MS ON MS.ServiceID=TD.ServiceID AND (MS.IsDeleted=0 OR MS.IsDeleted IS NULL)
INNER JOIN [AVL].[DEBT_MAS_DebtClassification](NOLOCK) DDC ON DDC.DebtClassificationID=TD.DebtClassificationMapID AND (DDC.IsDeleted=0 OR DDC.IsDeleted IS NULL)
WHERE (TD.TicketCreateDate BETWEEN @FromDate AND @ToDate ) AND TD.DARTStatusID IN (8,9) 
UNION ALL

SELECT  
TD.TicketID AS [Ticket Number],APM.TowerID AS [Application  ID/Tower ID] ,
TowerName AS [Application Name/Tower Name],TD.TicketCreateDate AS [Ticket Created On],
MPM.PriorityName AS [Priority],
TD.EffortTillDate AS [Efforts],
--'NEED TO UPDATE' AS [Ticket Resolution Date],
DC.DebtClassificationName AS [Debt Classification Name],
RD.ResidualDebtName AS [Residual Debt Name],
AF.AvoidableFlagName AS [Avoidable Flag Name],
--'NEED TO UPDATE' AS [Task Type],
AGM.AssignmentGroupName AS [Assignment Group],
TD.ResolutionRemarks AS [Resolution Notes],
TD.TimeTickerID AS [Time Ticker ID],
C.CustomerName AS [Customer Name],
BU.BUName AS [BU Name],
'' AS [Technology Name],
CC.CauseCode AS [Cause Code],
RC.ResolutionCode AS [Resolution Code],
DTS.DARTStatusName AS [Ticket Status],
'' AS [Service],
TD.ClosedDate AS [Closed Date],
DC.DebtClassificationName AS [Debt Classification Mode],
PM.ProjectId AS [Project ID ],
PM.ProjectName AS [Project Name],
'INFRA' AS[TicketType]

FROM [AVL].TK_TRN_InfraTicketDetail(NOLOCK) TD 
INNER JOIN AVL.TK_MAP_PriorityMapping(NOLOCK) MPM ON TD.PriorityMapID=MPM.PriorityIDMapID AND (MPM.IsDeleted=0 OR MPM.IsDeleted IS NULL) 
INNER JOIN AVL.DEBT_MAS_DebtClassificationInfra(NOLOCK) DC ON TD.DebtClassificationMapID=DC.DebtClassificationID AND (DC.IsDeleted=0 OR DC.IsDeleted IS NULL) 
INNER JOIN AVL.DEBT_MAS_ResidualDebt(NOLOCK) RD ON TD.ResidualDebtMapID = RD.ResidualDebtID AND (RD.IsDeleted=0 OR RD.IsDeleted IS NULL)
INNER JOIN AVL.DEBT_MAS_AvoidableFlag(NOLOCK) AF ON TD.AvoidableFlag=AF.AvoidableFlagID AND (AF.IsDeleted=0 OR AF.IsDeleted IS NULL)
INNER JOIN AVL.BOTAssignmentGroupMapping(NOLOCK) AGM ON TD.AssignmentGroupID= AGM.AssignmentGroupMapID AND (AGM.IsDeleted=0 OR AGM.IsDeleted IS NULL)
INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM ON PM.Projectid=TD.ProjectId AND (PM.IsDeleted=0 OR PM.IsDeleted IS NULL)
INNER JOIN AVL.InfraTowerProjectMapping(NOLOCK) APM  ON  PM.ProjectID=APM.ProjectID AND TD.TowerID=APM.TowerID  AND APM.IsDeleted  = 0
INNER JOIN [AVL].[InfraTowerDetailsTransaction] (NOLOCK) IDT ON IDT.InfraTowerTransactionID=APM.TowerId AND IDT.IsDeleted = 0
INNER JOIN AVL.Customer(NOLOCK) C ON C.CustomerID=PM.CustomerID AND (C.IsDeleted=0 OR C.IsDeleted IS NULL)
INNER JOIN AVL.BusinessUnit(NOLOCK) BU ON BU.BUID=C.BUID AND (BU.IsDeleted=0 OR BU.IsDeleted IS NULL)
INNER JOIN AVL.DEBT_MAP_CauseCode(NOLOCK) CC ON TD.CausecodeMapID=CC.CauseID AND (CC.IsDeleted=0 OR CC.IsDeleted IS NULL)
INNER JOIN AVL.DEBT_MAP_ResolutionCode(NOLOCK) RC ON TD.ResolutioncodeMapID=RC.ResolutionID AND (RC.IsDeleted=0 OR RC.IsDeleted IS NULL)
INNER JOIN AVL.TK_MAS_DARTTicketStatus(NOLOCK) DTS ON TD.DARTStatusID=DTS.DARTStatusID AND DTS.IsDeleted=0 AND (DTS.IsDeleted=0 OR DTS.IsDeleted IS NULL)
WHERE (TD.TicketCreateDate BETWEEN @FromDate AND @ToDate) AND TD.DARTStatusID IN (8,9) 
 
 SET NOCOUNT OFF  
 
 END TRY  
  
 BEGIN CATCH  
  DECLARE @ErrorMessage VARCHAR(4000);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error                                      
  EXEC AVL_InsertError '[AVL].[GetDebtRelatedDetails]'  
   ,@ErrorMessage  
   ,0  
 END CATCH  
END
