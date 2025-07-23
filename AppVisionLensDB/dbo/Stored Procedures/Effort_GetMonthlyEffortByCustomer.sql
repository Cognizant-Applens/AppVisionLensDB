/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[Effort_GetMonthlyEffortByCustomer]

	@CognizantID VARCHAR(1000),

	@FromDate DATE,

	@ToDate DATE,

	@CustomerID BIGINT

AS  

BEGIN  

BEGIN TRY

	SET NOCOUNT ON;  

	CREATE TABLE #Apptable
	(
		TicketID NVARCHAR(50),
		DARTStatusID INT
	)
	CREATE TABLE #Infratable
	(
		TicketID NVARCHAR(50),
		DARTStatusID INT
	)
	CREATE TABLE #AppInfraCount
	( 
		TicketID NVARCHAR(50),
		DARTStatusID INT,
		IDARTStatusID INT,
		Closeddate DATETIME,
		ICloseddate DATETIME
	)
	CREATE TABLE #workitemtable
	(
		WorkItem_Id NVARCHAR(100),
		StatusId BIGINT
	)

	DECLARE @AppEffort DECIMAL(5,2);
	DECLARE @InfraEffort DECIMAL(5,2);
	DECLARE @ClosedTickets INT;
	DECLARE @TicketedEffort NVARCHAR(100);
	DECLARE @AppNonTicketedEffort DECIMAL(5,2);
	DECLARE @InfraNonTicketedEffort DECIMAL(5,2);
	DECLARE @NonTicketedEffort NVARCHAR(100);
	DECLARE @ClosedWorkItems INT;
	DECLARE @WorkTicketedEffort DECIMAL(5,2);
	DECLARE @WorkItemEffort DECIMAL(5,2);
	DECLARE @WorkNonTicketedEffort DECIMAL(5,2);
	DECLARE @TotalEfforts  DECIMAL(5,2);

	SELECT LM.UserId,LM.EmployeeId,LM.ProjectId 
	INTO #MAS_LoginMaster
	FROM AVL.MAS_Loginmaster(NOLOCK) LM
	JOIN AVL.MAS_ProjectMaster (NOLOCK) PM
	ON PM.ProjectId = Lm.ProjectId AND PM.Isdeleted = 0 and LM.Isdeleted = 0
	WHERE LM.EmployeeId = @CognizantID AND PM.CustomerId = @CustomerID 

	INSERT INTO #Apptable (TicketID,DARTStatusID) 
	(SELECT  TD.TicketID,TD.DARTStatusID FROM AVL.TK_TRN_TicketDetail(NOLOCK) TD
	LEFT JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) ITD ON ITD.ProjectID=TD.ProjectID AND ITD.TicketID=TD.TicketID		
	INNER JOIN 	AVL.MAS_LoginMaster(NOLOCK) LM ON LM.UserID=TD.AssignedTo 
	AND LM.ProjectID=TD.ProjectID AND LM.isdeleted=0
	INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON  PM.ProjectID=LM.ProjectID AND PM.IsDeleted = 0
	INNER JOIN [AVL].[Customer](NOLOCK) C ON C.CustomerID=PM.CustomerID AND C.IsDeleted = 0
 	WHERE  LM.EmployeeID= @CognizantID AND C.CustomerID=@CustomerID AND convert(date,TD.Closeddate) BETWEEN @FromDate AND @ToDate
	AND (TD.DARTStatusID=8) AND ITD.TicketID IS NULL)
	

	INSERT INTO #Infratable (TicketID,DARTStatusID) 
	(SELECT  ITD.TicketID,ITD.DARTStatusID FROM AVL.TK_TRN_InfraTicketDetail(NOLOCK) ITD
	 LEFT JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD ON ITD.ProjectID=TD.ProjectID AND ITD.TicketID=TD.TicketID	
	 INNER JOIN AVL.MAS_LoginMaster(NOLOCK) LM ON LM.UserID=ITD.AssignedTo 
	 AND LM.ProjectID=ITD.ProjectID AND LM.isdeleted=0 
	 INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.ProjectID=LM.ProjectID AND PM.IsDeleted = 0
	 INNER JOIN [AVL].[Customer](NOLOCK) C ON C.CustomerID=PM.CustomerID AND C.IsDeleted = 0
 	 WHERE  LM.EmployeeID= @CognizantID AND C.CustomerID=@CustomerID AND convert(date,ITD.Closeddate) BETWEEN @FromDate AND @ToDate
	 AND (ITD.DARTStatusID=8) AND TD.TicketID IS NULL)
	
	 				
	INSERT INTO #AppInfraCount  
	SELECT A.TicketID,A.DARTStatusID,I.DARTStatusID,A.Closeddate,I.Closeddate FROM AVL.TK_TRN_TicketDetail(NOLOCK) A 
	INNER JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) I ON I.ProjectID=A.ProjectID AND A.TicketID=I.TicketID
	INNER JOIN 	AVL.MAS_LoginMaster(NOLOCK) LM ON LM.UserID=A.AssignedTo AND 
	LM.UserID=I.AssignedTo AND LM.ProjectID = I.ProjectID AND LM.ProjectID = A.ProjectID AND LM.isdeleted=0 
	INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON  PM.ProjectID=LM.ProjectID AND PM.IsDeleted = 0
	INNER JOIN [AVL].[Customer](NOLOCK) C ON C.CustomerID=PM.CustomerID AND C.IsDeleted = 0
	WHERE LM.EmployeeID= @CognizantID AND C.CustomerID=@CustomerID AND (A.DARTStatusID=8 OR I.DARTStatusID=8)
	AND ((convert(date,I.Closeddate) BETWEEN @FromDate AND @ToDate) OR (convert(date,A.Closeddate) BETWEEN @FromDate AND @ToDate))
	

	SET  @AppEffort = (SELECT SUM(TD.Hours) FROM AVL.TM_TRN_TimesheetDetail(NOLOCK) TD
	INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) TS ON TD.TimesheetId=TS.TimesheetId AND TD.ProjectId=TS.ProjectID AND TD.IsDeleted = 0
	INNER JOIN AVL.MAS_LoginMaster(NOLOCK) LM ON TD.ProjectID=LM.ProjectID AND TS.SubmitterId=LM.UserID AND LM.isdeleted=0 
	INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON  PM.ProjectID=LM.ProjectID AND PM.IsDeleted = 0
	INNER JOIN [AVL].[Customer](NOLOCK) C ON C.CustomerID=PM.CustomerID AND C.IsDeleted = 0
	WHERE LM.EmployeeID= @CognizantID  AND C.CustomerID=@CustomerID
	AND TS.TimesheetDate BETWEEN @FromDate AND @ToDate AND ISNULL(TD.IsNonTicket,0) =0)

	SET  @InfraEffort = (SELECT SUM(ITD.Hours) FROM AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) ITD
	INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) TS ON ITD.TimesheetId=TS.TimesheetId AND ITD.ProjectId=TS.ProjectID AND ITD.IsDeleted = 0
	INNER JOIN AVL.MAS_LoginMaster(NOLOCK) LM ON ITD.ProjectID=LM.ProjectID AND TS.SubmitterId=LM.UserID AND LM.isdeleted=0 
	INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON  PM.ProjectID=LM.ProjectID AND PM.IsDeleted = 0
	INNER JOIN [AVL].[Customer](NOLOCK) C ON C.CustomerID=PM.CustomerID AND C.IsDeleted = 0
	WHERE LM.EmployeeID= @CognizantID  AND C.CustomerID=@CustomerID
	AND TS.TimesheetDate BETWEEN @FromDate AND @ToDate AND ISNULL(ITD.IsNonTicket,0) =0)

	
	SET @AppNonTicketedEffort = (SELECT SUM(TD.Hours) FROM AVL.TM_TRN_TimesheetDetail(NOLOCK) TD
	INNER JOIN AVL.TM_PRJ_Timesheet (NOLOCK) TS ON TD.TimesheetId=TS.TimesheetId AND TD.ProjectId=TS.ProjectID AND TD.IsDeleted = 0
	INNER JOIN AVL.MAS_LoginMaster (NOLOCK)  LM ON TS.SubmitterId=LM.UserID AND TD.ProjectID = LM.ProjectID AND LM.isdeleted=0
	WHERE LM.EmployeeID = @CognizantID AND TS.CustomerID=@CustomerID 
	AND TS.TimesheetDate BETWEEN @FromDate AND @ToDate AND ISNULL(TD.IsNonTicket,0) =1);

	SET @InfraNonTicketedEffort = (SELECT SUM(TD.Hours) FROM AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) TD
	INNER JOIN AVL.TM_PRJ_Timesheet (NOLOCK) TS ON TD.TimesheetId=TS.TimesheetId AND TD.ProjectId=TS.ProjectID AND TD.IsDeleted = 0
	INNER JOIN AVL.MAS_LoginMaster (NOLOCK)  LM ON TS.SubmitterId=LM.UserID  AND TD.ProjectId = LM.ProjectId AND LM.isdeleted=0
	WHERE LM.EmployeeID = @CognizantID AND TS.CustomerID=@CustomerID  
	AND TS.TimesheetDate BETWEEN @FromDate AND @ToDate AND ISNULL(TD.IsNonTicket,0) =1);

	INSERT INTO #workitemtable (WorkItem_Id,StatusId) 
	SELECT distinct  WID.WorkItem_Id,S.StatusMapId FROM [ADM].[ALM_TRN_WorkItem_Details](NOLOCK) WID
    INNER JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) WTD ON WTD.WorkItemDetailsId=WID.WorkItemDetailsId AND WID.IsDeleted = 0  AND WTD.IsDeleted = 0
    INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) TS ON TS.TimesheetId=WTD.TimesheetId AND WID.Project_ID = TS.ProjectId
    INNER JOIN [PP].[ALM_MAP_Status](NOLOCK) S ON S.StatusMapId=WID.StatusMapId  AND S.IsDeleted = 0
    INNER JOIN  #MAS_LoginMaster(NOLOCK) LM ON LM.UserID=TS.SubmitterId
    AND LM.ProjectID=WID.Project_Id 
    INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.ProjectID=WID.Project_Id AND PM.IsDeleted = 0
    INNER JOIN [AVL].[Customer](NOLOCK) C ON C.CustomerID=PM.CustomerID AND C.IsDeleted = 0 WHERE  
	LM.EmployeeID= @CognizantID AND
	C.CustomerID=@CustomerID AND TS.TimesheetDate BETWEEN @FromDate AND @ToDate
    AND (S.StatusId=4)		
	
	SET  @WorkTicketedEffort = (SELECT SUM(WTD.Hours) FROM [ADM].[TM_TRN_WorkItemTimesheetDetail](NOLOCK) WTD
	INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) TS ON WTD.TimesheetId=TS.TimesheetId  AND WTD.IsDeleted = 0
	INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON TS.ProjectID=LM.ProjectID AND TS.SubmitterId=LM.UserID 
	INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON  PM.ProjectID=LM.ProjectID AND PM.IsDeleted = 0
	INNER JOIN [AVL].[Customer](NOLOCK) C ON C.CustomerID=PM.CustomerID AND C.IsDeleted = 0
	WHERE LM.EmployeeID= @CognizantID  AND C.CustomerID=@CustomerID
	AND TS.TimesheetDate BETWEEN @FromDate AND @ToDate AND ISNULL(WTD.IsNonTicket,0) =0)

	SET @WorkNonTicketedEffort = (SELECT SUM(WTD.Hours) FROM [ADM].[TM_TRN_WorkItemTimesheetDetail](NOLOCK) WTD
	INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) TS ON WTD.TimesheetId=TS.TimesheetId AND WTD.IsDeleted = 0
	INNER JOIN #MAS_LoginMaster(NOLOCK)  LM ON TS.SubmitterId=LM.UserID AND TS.ProjectID = LM.ProjectID 
	WHERE LM.EmployeeID = @CognizantID AND TS.CustomerID=@CustomerID 
	AND TS.TimesheetDate BETWEEN @FromDate AND @ToDate AND ISNULL(WTD.IsNonTicket,0) =1);
				
	SET @ClosedTickets=(SELECT (SELECT count(1) FROM #Apptable(NOLOCK)) + (SELECT  count(1) FROM #Infratable(NOLOCK))	
						+(SELECT  count(1) FROM #AppInfraCount(NOLOCK)) as TotalCount);

	SET @TicketedEffort= (SELECT SUM(ISNULL(@AppEffort,0)+ISNULL(@InfraEffort,0)) as TicketedEffort);
	
	SET @NonTicketedEffort = (SELECT SUM(ISNULL(@AppNonTicketedEffort,0)+ISNULL(@InfraNonTicketedEffort,0) +ISNULL(@WorkNonTicketedEffort,0)));

	SET @ClosedWorkItems = (select count(1) from #workitemtable(NOLOCK));

	SET @WorkItemEffort = (SELECT SUM(ISNULL(@WorkTicketedEffort,0)) as workEffort);

	SET @TotalEfforts = (SELECT SUM(ISNULL(@WorkTicketedEffort,0) + ISNULL(@WorkNonTicketedEffort,0)+
	                        ISNULL(@AppEffort,0)+ ISNULL(@InfraEffort,0)
	               +ISNULL(@AppNonTicketedEffort,0)+ISNULL(@InfraNonTicketedEffort,0)) as TotalworkEffort);

	SELECT ISNULL(@ClosedTickets,0) AS ClosedTickets,
	ISNULL(@TicketedEffort,0) AS TicketedEffort,
	ISNULL(@NonTicketedEffort,0) AS NonTicketedEffort,
	ISNULL(@ClosedWorkItems,0) AS ClosedWorkItems,
	ISNULL(@WorkItemEffort,0) AS WorkItemEffort,
	ISNULL(@TotalEfforts,0) AS TotalEfforts

	DROP Table #Apptable
	DROP Table #Infratable	
	DROP Table #AppInfraCount
	DROP Table #workitemtable



SET NOCOUNT OFF;  

END TRY  

BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		EXEC AVL_InsertError '[dbo].[Effort_GetMonthlyEffortByCustomer] ', @ErrorMessage, 0, @CognizantID

	END CATCH  

END
