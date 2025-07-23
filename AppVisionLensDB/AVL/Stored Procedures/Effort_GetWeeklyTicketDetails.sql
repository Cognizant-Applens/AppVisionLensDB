/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE Procedure [AVL].[Effort_GetWeeklyTicketDetails]
@CustomerID BIGINT,
@EmployeeID NVARCHAR(50)=null ,
@FirstDateOfWeek VARCHAR(30)=null,
@LastDateOfWeek VARCHAR(30)=null
AS 
BEGIN
BEGIN TRY
	SET NOCOUNT ON;

	DECLARE @Servicecount INT
	DECLARE @IsDaily INT;
	SET @Servicecount=0;
	---To get date between start and end date
	CREATE TABLE #EFFORTDATES
	(
	SNO INT IDENTITY(1,1),
	DATETODAY DATE,
	NAME VARCHAR(50),
	FreezeStatus NVARCHAR(50)
	)
	
	CREATE TABLE #TimesheetTemp
	(
	TimesheetId  BIGINT NOT NULL,
	CustomerID BIGINT NOT NULL,
	ProjectID BIGINT NOT NULL,
	SubmitterID NVARCHAR(50),
	TimesheetDate DATE NOT NULL,
	StatusId numeric(6,0)  NULL,

	)
	CREATE TABLE #MAS_LoginMaster
	(
		[UserID] [int]  NOT NULL,
		[EmployeeID] [nvarchar](50) NOT NULL,
		[EmployeeName] [nvarchar](100) NULL,
		[ProjectID] [int] NOT NULL,
		[CustomerID] [bigint] NOT NULL,
		[TimeZoneId] [int] NULL
	)

	CREATE CLUSTERED INDEX IDX_UserID_EmployeeID_ProjectID_CustomerID_LM ON #MAS_LoginMaster (UserID,EmployeeID,ProjectID,CustomerID)
	;WITH MYCTE AS
	(
	SELECT CAST(@FirstDateOfWeek AS DATETIME) DATEVALUE
	UNION ALL
	SELECT  DATEVALUE + 1
	FROM    MYCTE   
	WHERE   DATEVALUE + 1 <= @LastDateOfWeek
	)
	INSERT INTO #EFFORTDATES
	SELECT  CONVERT(DATE,DATEVALUE) AS DATETODAY , DATENAME(W,DATEVALUE) AS NAME,''
	FROM    MYCTE 
	OPTION (MAXRECURSION 0)


	INSERT INTO #MAS_LoginMaster
	( UserID,EmployeeID,EmployeeName,ProjectID,CustomerID,TimeZoneId)
	SELECT UserID,EmployeeID,EmployeeName,ProjectID,CustomerID,TimeZoneId 
	FROM [AVL].[MAS_LoginMaster](NOLOCK) 
	WHERE EmployeeID = @EmployeeID AND CustomerID=@CustomerID AND ISNULL(IsDeleted,0)=0


	INSERT INTO #TimesheetTemp
	(TimesheetId,CustomerID,ProjectID, SubmitterID, TimesheetDate,StatusId)
	Select TimesheetId,TM.CustomerID, TM.ProjectID,TM.SubmitterId, TimesheetDate,StatusId FROM AVL.TM_PRJ_Timesheet TM (NOLOCK)
	INNER JOIN #MAS_LoginMaster LM 
	ON TM.CustomerID =@CustomerID AND TM.ProjectID=LM.ProjectID AND TM.SubmitterId=LM.UserID	 
	AND TimesheetDate BETWEEN @FirstDateOfWeek AND  @LastDateOfWeek 
	
	select 
	 WTD.TimesheetDetailID
	,WTD.TimeSheetId
	,WTD.WorkItemDetailsId
	,WTD.ServiceID
	,WTD.ActivityID
	,WTD.Hours
	,WTD.IsDeleted
	,WTD.IsNonTicket
	,WD.WorkItem_Id
	,WD.Project_Id
	Into #WorkItemTimesheetDetailTemp
	from [ADM].[TM_TRN_WorkItemTimesheetDetail](NOLOCK) WTD
	INNER JOIN #TimesheetTemp(NOLOCK) TT ON TT.TimesheetId = WTD.TimeSheetId 
	INNER JOIN ADM.ALM_TRN_WorkItem_Details(NOLOCK) WD ON WD.WorkItemDetailsId = WTD.WorkItemDetailsId AND WD.Project_Id = TT.ProjectID AND WTD.IsDeleted = 0 AND WD.IsDeleted = 0


	---To get the Config wrt project/customer
	SELECT DISTINCT
	C.CustomerId AS CustomerId,PM.ProjectID,
	ISNULL(CASE WHEN C.IsCognizant='0' THEN 0 ELSE 1 END,1)			AS IsCustomer,
	ISNULL(CASE WHEN C.IsCognizant='0' THEN 0 ELSE 1 END,1)			AS IsCognizant,
	ISNULL(C.IsEffortConfigured,0)		AS IsEfforTracked,
	ISNULL(CASE WHEN PM.IsDebtEnabled='Y' THEN 1 ELSE 0 END,0)			AS IsDebtEnabled,
	ISNULL(CASE WHEN PM.IsMainspringConfigured='Y' THEN 1 ELSE 0 END,0)	AS IsMainSpringConfigured,
	C.IsDaily,TM.TZoneName AS ProjectTimeZoneName Into #ConfigTemp
	FROM AVL.Customer C ( NOLOCK ) 
	INNER JOIN AVL.MAS_ProjectMaster PM ( NOLOCK ) ON C.CustomerID=PM.CustomerID AND PM.Isdeleted = 0 
	INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.CustomerID=C.CustomerID AND LM.ProjectID=PM.ProjectID
	LEFT JOIN AVL.MAP_ProjectConfig( NOLOCK ) PC ON PM.ProjectID=PC.ProjectID
	LEFT JOIN AVL.MAS_TimeZoneMaster( NOLOCK ) TM ON ISNULL(PC.TimeZoneId,32)=TM.TimeZoneID
	WHERE C.CustomerID=@CustomerID AND LM.EmployeeID=@EmployeeID AND C.IsDeleted = 0


	CREATE TABLE #TicketedTimesheetdetailsTemp
	(
	TimesheetId BIGINT NOT NULL,
	TimesheetDate DATE NULL,
	TimeSheetDetailId BIGINT NULL,
	TicketID NVARCHAR(100) NULL,
	ServiceId INT NULL,
	Effort DECIMAL(25,2) NULL,
	TimeTickerID BIGINT NULL,
	IsNonTicket BIT NULL,
	IsCustomer INT NULL,
	IsEfforTracked INT NULL,
	IsDebtEnabled INT NULL,
	IsMainSpringConfigured INT NULL,
	ActivityId INT NULL,
	ProjectTimeZoneName NVARCHAR(500) NULL,
	UserTimeZoneName  NVARCHAR(500) NULL,
	SupportTypeID INT NULL,
	[Type] varchar(10) null
	)
	CREATE TABLE #AutoAssignedTicketTempAll
	(
	CustomerID BIGINT NULL,
	ProjectID BIGINT NULL,
	ApplicationID BIGINT NULL,
	TicketID NVARCHAR(100) NULL,
	AssignedTo  BIGINT NULL,
	TimeTickerID BIGINT NULL,
	IsNonTicket INT NULL,
	IsCustomer INT NULL,
	IsEfforTracked INT NULL,
	IsDebtEnabled  INT NULL,
	IsMainSpringConfigured  INT NULL,
	ActivityId INT NULL,
	ProjectTimeZoneName NVARCHAR(500) NULL,
	UserTimeZoneName NVARCHAR(500) NULL,
	OpenDateTime DATE NULL,
	SupportTypeID INT NULL,
	ClosedDate DATETIME NULL,
	CompletedDate DATETIME NULL,
	[Type] varchar(10) null
	)
	CREATE TABLE #ClosedTicketWithNoEffortsAll
	(
	CustomerID BIGINT NULL,
	ProjectID BIGINT NULL,
	ApplicationID BIGINT NULL,
	TicketID  NVARCHAR(100) NULL,
	AssignedTo BIGINT NULL,
	TimeTickerID BIGINT NULL,
	IsNonTicket  INT NULL,
	IsCustomer INT NULL,
	IsEfforTracked INT NULL,
	IsDebtEnabled INT NULL,
	IsMainSpringConfigured INT NULL,
	ActivityId INT NULL,
	ProjectTimeZoneName NVARCHAR(500) NULL,
	UserTimeZoneName NVARCHAR(500) NULL,
	OpenDateTime DATE NULL,
	SupportTypeID INT NULL,
	ClosedDate DATETIME NULL,
	CompletedDate DATETIME NULL,
	[Type] varchar(10) null
	)
	CREATE TABLE #NonTicketedTimesheetdetailsTemp
	(
	TimesheetId BIGINT NULL,
	TimesheetDate DATE NULL,
	TimeSheetDetailId BIGINT NULL,
	TicketID NVARCHAR(100) NULL,
	Effort DECIMAL(25,2) NULL,
	TimeTickerID BIGINT NULL,
	IsNonTicket  INT NULL,
	IsCustomer  INT NULL,
	IsEfforTracked  INT NULL,
	IsDebtEnabled  INT NULL,
	IsMainSpringConfigured  INT NULL,
	ActivityId  INT NULL,
	ProjectTimeZoneName NVARCHAR(500) NULL,
	UserTimeZoneName NVARCHAR(500) NULL,
	Activity NVARCHAR(100) NULL,
	AssignedTo BIGINT NULL,
	ProjectId BIGINT NULL,
	SupportTypeID INT NULL,
	[Type] varchar(10) null
	)
	CREATE TABLE #EffortEntryDataTemp
	(
	TimesheetId BIGINT NULL,
	TimesheetDate DATE NULL,
	TimeSheetDetailId BIGINT NULL,
	TimeTickerID BIGINT NULL,
	TicketID NVARCHAR(100) NULL,
	ApplicationID BIGINT NULL,
	ProjectID BIGINT NULL,
	AssignedTo BIGINT NULL,
	EffortTillDate DECIMAL(25,2) NULL,
	Effort DECIMAL(25,2) NULL,
	ServiceID INT NULL,
	TicketDescription NVARCHAR(MAX) NULL,
	IsDeleted  INT NULL,
	TicketStatusMapID BIGINT NULL,
	TicketTypeMapID BIGINT NULL,
	IsSDTicket  INT NULL,
	DARTStatusID INT NULL,
	ITSMEffort  DECIMAL(25,2) NULL,
	IsNonTicket INT NULL,
	IsCustomer INT NULL,
	IsEfforTracked INT NULL,
	IsDebtEnabled CHAR(1) NULL,
	IsMainSpringConfigured CHAR(1) NULL,
	ISTicket INT NULL,
	ActivityId INT NULL,
	ProjectTimeZoneName NVARCHAR(500) NULL,
	UserTimeZoneName NVARCHAR(500) NULL,
	TowerID BIGINT NULL,
	SupportTypeID INT NULL,
	ClosedDate DATETIME NULL,
	CompletedDate DATETIME NULL,
	[Type] varchar(10) null
	)
		-- to get the Ticketed effort
		INSERT INTO #TicketedTimesheetdetailsTemp
		SELECT  DISTINCT PT.TimesheetId ,PT.TimesheetDate  AS TimesheetDate,TD.TimeSheetDetailId,TD.TicketID,TD.ServiceId,
		TD.Hours AS Effort,TD.TimeTickerID ,TD.IsNonTicket,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,
		CT.IsMainSpringConfigured,TD.ActivityId
		,CT.ProjectTimeZoneName  as ProjectTimeZoneName,ZM.TZoneName AS UserTimeZoneName,1,'T'
		FROM #TimesheetTemp(NOLOCK) PT
		INNER JOIN AVL.TM_TRN_TimesheetDetail(NOLOCK) TD ON  PT.ProjectID=TD.ProjectId AND PT.TimesheetId=TD.TimesheetId 
		AND ISNULL(TD.IsDeleted,0)=0
		INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.CustomerId=PT.CustomerID AND LM.ProjectID=PT.ProjectID AND PT.SubmitterId=LM.UserID 
		INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0
		INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.CustomerID=C.CustomerID and PM.ProjectID=LM.ProjectID AND PM.Isdeleted = 0
		INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=LM.CustomerID  and CT.ProjectID=TD.ProjectId
		LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) ZM ON LM.TimeZoneId=ZM.TimeZoneID
		WHERE LM.CustomerID = @CustomerID AND LM.EmployeeID = @EmployeeID and ISNULL(TD.IsNonTicket,0)=0
		AND TimesheetDate BETWEEN @FirstDateOfWeek AND @LastDateOfWeek 



		 -- to get the Ticketed effort Infra
		INSERT INTO #TicketedTimesheetdetailsTemp
		SELECT  DISTINCT PT.TimesheetId ,PT.TimesheetDate  AS TimesheetDate,TD.TimeSheetDetailId,TD.TicketID, 0 AS ServiceId,--TD.CategoryId AS ServiceId,
		TD.Hours AS Effort,TD.TimeTickerID ,TD.IsNonTicket,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,
		CT.IsMainSpringConfigured,TD.TaskID as ActivityId
		,CT.ProjectTimeZoneName  as ProjectTimeZoneName,ZM.TZoneName AS UserTimeZoneName,2,'T'
		FROM #TimesheetTemp(NOLOCK) PT
		INNER JOIN AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) TD ON  PT.ProjectID=TD.ProjectId AND PT.TimesheetId=TD.TimesheetId 
		AND ISNULL(TD.IsDeleted,0)=0
		INNER JOIN #MAS_LoginMaster LM ON LM.CustomerId=PT.CustomerID AND LM.ProjectID=PT.ProjectID AND PT.SubmitterId=LM.UserID 
		INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0
		INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.CustomerID=C.CustomerID and PM.ProjectID=LM.ProjectID AND PM.IsDeleted = 0
		INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=LM.CustomerID  and CT.ProjectID=TD.ProjectId
		LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) ZM ON LM.TimeZoneId=ZM.TimeZoneID
		WHERE LM.CustomerID = @CustomerID AND LM.EmployeeID = @EmployeeID and ISNULL(TD.IsNonTicket,0)=0
		AND TimesheetDate BETWEEN @FirstDateOfWeek AND @LastDateOfWeek 

		-- to get the Non Ticketed effort
		INSERT 	INTO #NonTicketedTimesheetdetailsTemp
		SELECT  DISTINCT PT.TimesheetId,PT.TimesheetDate  AS TimesheetDate,TD.TimeSheetDetailId,TD.TicketID AS TicketID,TD.Hours AS Effort,TD.TimeTickerID,TD.IsNonTicket 
		,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,CT.IsMainSpringConfigured,TD.ActivityId,
		CT.ProjectTimeZoneName AS ProjectTimeZoneName,ZM.TZoneName AS UserTimeZoneName
		,NDM.NonTicketedActivity AS Activity,LM.UserID AS AssignedTo,TD.ProjectId,1,'ND'
		FROM #TimesheetTemp(NOLOCK) PT
		INNER JOIN AVL.TM_TRN_TimesheetDetail(NOLOCK) TD ON  PT.TimesheetId=TD.TimesheetId AND PT.ProjectID=TD.ProjectId AND TD.IsDeleted = 0
		INNER JOIN #MAS_LoginMaster LM ON LM.CustomerID=PT.CustomerID AND LM.ProjectID=PT.ProjectID
		AND LM.UserID = PT.SubmitterId 
		INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0
		LEFT JOIN AVL.MAS_NonDeliveryActivity(NOLOCK) NDM ON TD.ActivityId=NDM.ID AND TD.ISNONTicket=1
		INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=C.CustomerID
		LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) ZM ON LM.TimeZoneId=ZM.TimeZoneID
		WHERE  PT.CustomerID=@CustomerID AND LM.EmployeeID = @EmployeeID and  TD.IsNonTicket = 1
		AND TimesheetDate BETWEEN @FirstDateOfWeek AND @LastDateOfWeek 
		AND ISNULL(TD.IsDeleted,0)=0


	

		-- to get the Non Ticketed effort
		INSERT 	INTO #NonTicketedTimesheetdetailsTemp
		SELECT  DISTINCT PT.TimesheetId,PT.TimesheetDate  AS TimesheetDate,TD.TimeSheetDetailId,'NonDelivery'AS TicketID,TD.Hours AS Effort,nULL AS TimeTickerID,TD.IsNonTicket 
		,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,CT.IsMainSpringConfigured,TD.ActivityId,
		CT.ProjectTimeZoneName AS ProjectTimeZoneName,ZM.TZoneName AS UserTimeZoneName
		,NDM.NonTicketedActivity AS Activity,LM.UserID AS AssignedTo,LM.ProjectId,0,'ND'
		FROM #TimesheetTemp(NOLOCK) PT
		INNER JOIN [ADM].[TM_TRN_WorkItemTimesheetDetail](NOLOCK) TD ON  PT.TimesheetId=TD.TimesheetId   
		INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.CustomerID=PT.CustomerID AND LM.ProjectID=PT.ProjectID
		AND LM.UserID = PT.SubmitterId 
		INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0
		LEFT JOIN AVL.MAS_NonDeliveryActivity(NOLOCK) NDM ON TD.ActivityId=NDM.ID AND TD.ISNONTicket=1
		INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=C.CustomerID
		LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) ZM ON LM.TimeZoneId=ZM.TimeZoneID
		WHERE  PT.CustomerID=@CustomerID AND LM.EmployeeID = @EmployeeID and  TD.IsNonTicket = 1
		AND TimesheetDate BETWEEN @FirstDateOfWeek AND @LastDateOfWeek 
		AND ISNULL(TD.IsDeleted,0)=0



		INSERT  INTO #NonTicketedTimesheetdetailsTemp
		SELECT  DISTINCT PT.TimesheetId,PT.TimesheetDate  AS TimesheetDate,TD.TimeSheetDetailId,TD.TicketID AS TicketID,TD.Hours AS Effort,TD.TimeTickerID,TD.IsNonTicket 
		,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,CT.IsMainSpringConfigured,TD.TaskId AS ActivityId,
		CT.ProjectTimeZoneName AS ProjectTimeZoneName,ZM.TZoneName AS UserTimeZoneName
		,NDM.NonTicketedActivity AS Activity,LM.UserID AS AssignedTo,TD.ProjectId,2,'ND'
		FROM #TimesheetTemp(NOLOCK) PT
		INNER JOIN AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) TD ON  PT.TimesheetId=TD.TimesheetId AND PT.ProjectID=TD.ProjectId 
		AND ISNULL(TD.IsDeleted,0)=0
		INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.CustomerID=PT.CustomerID AND LM.ProjectID=PT.ProjectID
		AND LM.UserID = PT.SubmitterId 
		INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID
		LEFT JOIN AVL.MAS_NonDeliveryActivity(NOLOCK) NDM ON TD.TaskId=NDM.ID AND TD.ISNONTicket=1
		INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=C.CustomerID AND C.IsDeleted = 0
		LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) ZM ON LM.TimeZoneId=ZM.TimeZoneID
		WHERE  PT.CustomerID=@CustomerID AND LM.EmployeeID = @EmployeeID and  TD.IsNonTicket = 1
		AND TimesheetDate BETWEEN @FirstDateOfWeek AND @LastDateOfWeek 
		


		--new
		INSERT INTO #TicketedTimesheetdetailsTemp
		SELECT  DISTINCT PT.TimesheetId ,PT.TimesheetDate  AS TimesheetDate,TD.TimeSheetDetailId,TD.WorkItem_Id,TD.ServiceId,
		TD.Hours AS Effort,TD.WorkItemDetailsId ,TD.IsNonTicket,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,
		CT.IsMainSpringConfigured,TD.ActivityId
		,CT.ProjectTimeZoneName  as ProjectTimeZoneName,ZM.TZoneName AS UserTimeZoneName,0,'W'
		FROM #TimesheetTemp(NOLOCK) PT
		INNER JOIN #WorkItemTimesheetDetailTemp(NOLOCK) TD ON  PT.ProjectID=TD.Project_Id AND PT.TimesheetId=TD.TimesheetId 
		AND ISNULL(TD.IsDeleted,0)=0
		INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.CustomerId=PT.CustomerID AND LM.ProjectID=PT.ProjectID AND PT.SubmitterId=LM.UserID 
		INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0
		INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.CustomerID=C.CustomerID and PM.ProjectID=LM.ProjectID
		INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=LM.CustomerID  and CT.ProjectID=TD.Project_Id
		LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) ZM ON LM.TimeZoneId=ZM.TimeZoneID
		WHERE LM.CustomerID = @CustomerID AND LM.EmployeeID = @EmployeeID and ISNULL(TD.IsNonTicket,0)=0
		AND TimesheetDate BETWEEN @FirstDateOfWeek AND @LastDateOfWeek  

		SELECT Distinct UAG.AssignmentGroupMapID,AssignmentGroupName,BAG.ProjectID,BAG.SupportTypeID ,LM.UserID
		INTO #assignmentGrpData
		FROM AVL.BOTAssignmentGroupMapping(NOLOCK) BAG
		JOIN #ConfigTemp(NOLOCK) C 
		ON C.ProjectId = BAG.ProjectId AND BAG.IsDeleted = 0
		JOIN AVL.UserAssignmentGroupMapping(NOLOCK) UAG ON 
		UAG.AssignmentGroupMapID = BAG.AssignmentGroupMapID AND UAG.ProjectID = BAG.ProjectID AND UAG.IsDeleted = 0
		JOIN #MAS_LoginMaster LM (NOLOCK) ON LM.UserID = UAG.UserID AND LM.ProjectID = UAG.ProjectID
		WHERE C.CustomerID = @CustomerID AND LM.EmployeeID = @EmployeeID AND BAG.IsBOTGroup = 0

		-- to get the Auto assigned Tickets
		INSERT INTO #AutoAssignedTicketTempAll
		SELECT  TOP 100 LM.CustomerID,TD.ProjectID, TD.ApplicationID,TD.TicketID,TD.AssignedTo,TD.TimeTickerID ,0 as IsNonTicket
		,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,CT.IsMainSpringConfigured,null as ActivityId,
		CT.ProjectTimeZoneName AS ProjectTimeZoneName,ZM.TZoneName AS UserTimeZoneName,
		TD.OpenDateTime,1,TD.Closeddate AS ClosedDate,TD.CompletedDateTime AS CompletedDate,'T'
		from [AVL].[TK_TRN_TicketDetail] TD WITH (NOLOCK) 
		INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.ProjectID=TD.ProjectID AND CONVERT(NVARCHAR(50),LM.UserID) =TD.AssignedTo
		INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0
		INNER JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) APM  ON  LM.ProjectID=APM.ProjectID AND TD.ApplicationID=APM.ApplicationID AND APM.IsDeleted = 0
		INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=LM.CustomerID  and CT.ProjectID=TD.ProjectId
		LEFT JOIN #TicketedTimesheetdetailsTemp(NOLOCK) TTDTemp ON TD.TimeTickerID=TTDTemp.TimeTickerID AND TTDTemp.SupportTypeID=1 and TTDTemp.[Type] ='T'
		LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) ZM ON LM.TimeZoneId=ZM.TimeZoneID
		WHERE LM.CustomerID =@CustomerID  and LM.EmployeeID =@EmployeeID
		AND  CONVERT(DATE,TD.OpenDateTime) BETWEEN DATEADD(DAY,-6,CONVERT(DATE,@FirstDateOfWeek)) AND CONVERT(DATE,@LastDateOfWeek) 
		AND ((ISNULL(TD.DARTStatusID,0) <> 8 AND ISNULL(TD.DARTStatusID,0) <> 13) OR (ISNULL(TD.DARTStatusID,0) = 8 AND ISNULL(TD.EffortTillDate,0) =0))
		AND TTDTemp.TimeTickerID IS NULL 
		ORDER BY TD.OpenDateTime DESC	

		--get others AG app tickets
		INSERT INTO #AutoAssignedTicketTempAll
		SELECT TOP 100 LM.CustomerID,TD.ProjectID, TD.ApplicationID,TD.TicketID,TD.AssignedTo,TD.TimeTickerID ,0 as IsNonTicket
		,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,CT.IsMainSpringConfigured,null as ActivityId,
		CT.ProjectTimeZoneName AS ProjectTimeZoneName,ZM.TZoneName AS UserTimeZoneName,
		TD.OpenDateTime,1,TD.Closeddate AS ClosedDate,TD.CompletedDateTime AS CompletedDate,'T'
		from [AVL].[TK_TRN_TicketDetail] TD WITH (NOLOCK) 
		INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.ProjectID=TD.ProjectID
		INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0
		INNER JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) APM  ON  LM.ProjectID=APM.ProjectID AND TD.ApplicationID=APM.ApplicationID AND APM.IsDeleted = 0
		INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=LM.CustomerID  and CT.ProjectID=TD.ProjectId
		INNER JOIN #assignmentGrpData(NOLOCK) AG ON AG.AssignmentGroupMapID = TD.AssignmentGroupID AND AG.ProjectID = TD.ProjectID  AND AG.SupportTypeID = 1
		LEFT JOIN #TicketedTimesheetdetailsTemp(NOLOCK) TTDTemp ON TD.TimeTickerID=TTDTemp.TimeTickerID AND TTDTemp.SupportTypeID=1 and TTDTemp.[Type] ='T'
		LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) ZM ON LM.TimeZoneId=ZM.TimeZoneID
		WHERE LM.CustomerID =@CustomerID  and LM.EmployeeID =@EmployeeID
		AND  CONVERT(DATE,TD.OpenDateTime) BETWEEN DATEADD(DAY,-6,CONVERT(DATE,@FirstDateOfWeek)) AND CONVERT(DATE,@LastDateOfWeek) 
		AND ((ISNULL(TD.DARTStatusID,0) <> 8 AND ISNULL(TD.DARTStatusID,0) <> 13) OR (ISNULL(TD.DARTStatusID,0) = 8 AND ISNULL(TD.EffortTillDate,0) =0))
		AND TTDTemp.TimeTickerID IS NULL 
		ORDER BY TD.OpenDateTime DESC	

		-- to get infra user assigned tickets
		INSERT INTO #AutoAssignedTicketTempAll
		SELECT  TOP 100 LM.CustomerID,TD.ProjectID, TD.TowerID AS ApplicationID,TD.TicketID,TD.AssignedTo,TD.TimeTickerID ,0 as IsNonTicket
		,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,CT.IsMainSpringConfigured,null as ActivityId,
		CT.ProjectTimeZoneName AS ProjectTimeZoneName,ZM.TZoneName AS UserTimeZoneName,
		TD.OpenDateTime ,2,TD.Closeddate AS ClosedDate,TD.CompletedDateTime AS CompletedDate,'T'
		from [AVL].[TK_TRN_InfraTicketDetail] TD WITH (NOLOCK) 
		INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.ProjectID=TD.ProjectID AND CONVERT(NVARCHAR(50),LM.UserID) =TD.AssignedTo
		INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0
		INNER JOIN AVL.InfraTowerProjectMapping(NOLOCK) APM  ON  LM.ProjectID=APM.ProjectID AND TD.TowerID=APM.TowerID
		INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=LM.CustomerID  and CT.ProjectID=TD.ProjectId
		LEFT JOIN #TicketedTimesheetdetailsTemp(NOLOCK) TTDTemp ON TD.TimeTickerID=TTDTemp.TimeTickerID AND TTDTemp.SupportTypeID=2 and TTDTemp.[Type] ='T'
		LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) ZM ON LM.TimeZoneId=ZM.TimeZoneID
		WHERE LM.CustomerID =@CustomerID  and LM.EmployeeID =@EmployeeID
		AND  CONVERT(DATE,TD.OpenDateTime) BETWEEN DATEADD(DAY,-6,CONVERT(DATE,@FirstDateOfWeek)) AND CONVERT(DATE,@LastDateOfWeek) 
		AND ((ISNULL(TD.DARTStatusID,0) <> 8 AND ISNULL(TD.DARTStatusID,0) <> 13) OR (ISNULL(TD.DARTStatusID,0) = 8 AND ISNULL(TD.EffortTillDate,0) =0))
		AND TTDTemp.TimeTickerID IS NULL 


		-- get others AG Infra Tickets
		INSERT INTO #AutoAssignedTicketTempAll
		SELECT  TOP 100 LM.CustomerID,TD.ProjectID, TD.TowerID AS ApplicationID,TD.TicketID,TD.AssignedTo,TD.TimeTickerID ,0 as IsNonTicket
		,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,CT.IsMainSpringConfigured,null as ActivityId,
		CT.ProjectTimeZoneName AS ProjectTimeZoneName,ZM.TZoneName AS UserTimeZoneName,
		TD.OpenDateTime ,2,TD.Closeddate AS ClosedDate,TD.CompletedDateTime AS CompletedDate,'T'
		from [AVL].[TK_TRN_InfraTicketDetail] TD WITH (NOLOCK) 
		INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.ProjectID=TD.ProjectID
		INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0
		INNER JOIN AVL.InfraTowerProjectMapping(NOLOCK) APM  ON  LM.ProjectID=APM.ProjectID AND TD.TowerID=APM.TowerID
		INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=LM.CustomerID  and CT.ProjectID=TD.ProjectId
		INNER JOIN #assignmentGrpData(NOLOCK) AG ON AG.AssignmentGroupMapID = TD.AssignmentGroupID AND AG.ProjectID = TD.ProjectID  AND AG.SupportTypeID = 2
		LEFT JOIN #TicketedTimesheetdetailsTemp(NOLOCK) TTDTemp ON TD.TimeTickerID=TTDTemp.TimeTickerID AND TTDTemp.SupportTypeID=2 and TTDTemp.[Type] ='T'
		LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) ZM ON LM.TimeZoneId=ZM.TimeZoneID
		WHERE LM.CustomerID =@CustomerID  and LM.EmployeeID =@EmployeeID
		AND  CONVERT(DATE,TD.OpenDateTime) BETWEEN DATEADD(DAY,-6,CONVERT(DATE,@FirstDateOfWeek)) AND CONVERT(DATE,@LastDateOfWeek) 
		AND ((ISNULL(TD.DARTStatusID,0) <> 8 AND ISNULL(TD.DARTStatusID,0) <> 13) OR (ISNULL(TD.DARTStatusID,0) = 8 AND ISNULL(TD.EffortTillDate,0) =0))
		AND TTDTemp.TimeTickerID IS NULL 

		SELECT TOP 100 * INTO #AutoAssignedTicketTemp FROM #AutoAssignedTicketTempAll
		ORDER BY OpenDateTime DESC
		-----New Block for Closed Tickets
		DECLARE @CountOftckt BIGINT 
		SELECT @CountOftckt=(ISNULL(TicketCount,50)) from AVL.Customer WHERE CustomerID=@CustomerID
		INSERT INTO #ClosedTicketWithNoEffortsAll
		SELECT TOP (@CountOftckt)  LM.CustomerID,TD.ProjectID, TD.ApplicationID,TD.TicketID,TD.AssignedTo,TD.TimeTickerID ,0 as IsNonTicket  
		,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,CT.IsMainSpringConfigured,null as ActivityId,  
		CT.ProjectTimeZoneName AS ProjectTimeZoneName,ZM.TZoneName AS UserTimeZoneName,  
		TD.OpenDateTime  ,1,TD.Closeddate AS ClosedDate,TD.CompletedDateTime AS CompletedDate,'T'
		from [AVL].[TK_TRN_TicketDetail](NOLOCK) TD   
		INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.ProjectID=TD.ProjectID AND LM.UserID =TD.AssignedTo  
		INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID AND C.IsDeleted = 0 
		INNER JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) APM  ON  LM.ProjectID=APM.ProjectID AND TD.ApplicationID=APM.ApplicationID AND APM.IsDeleted = 0
		INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=LM.CustomerID  and CT.ProjectID=TD.ProjectId  
		LEFT JOIN #TicketedTimesheetdetailsTemp(NOLOCK) TTDTemp ON TD.TimeTickerID=TTDTemp.TimeTickerID  and TTDTemp.[Type] ='T'
		LEFT JOIN #AutoAssignedTicketTemp(NOLOCK) ATT ON ATT.TimeTickerID=TD.TimeTickerID
		LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) ZM ON LM.TimeZoneId=ZM.TimeZoneID  
		WHERE LM.CustomerID =@CustomerID  and LM.EmployeeID =@EmployeeID  
		AND  CONVERT(DATE,TD.OpenDateTime) <= CONVERT(DATE,@LastDateOfWeek) AND
		Convert(Date,TD.Closeddate) BETWEEN Convert(Date,@FirstDateOfWeek) AND CONVERT(DATE,@LastDateOfWeek)
		AND TD.DARTStatusID=8 
		AND (TD.IsAttributeUpdated=0 OR TD.EffortTillDate=0)
		and TTDTemp.TimeTickerID IS NULL AND ATT.TimeTickerID IS NULL 
		ORDER BY TD.OpenDateTime DESC 


		INSERT INTO #ClosedTicketWithNoEffortsAll
		SELECT TOP (@CountOftckt)  LM.CustomerID,TD.ProjectID, TD.TowerID AS ApplicationID,TD.TicketID,TD.AssignedTo,TD.TimeTickerID ,0 as IsNonTicket  
		,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,CT.IsMainSpringConfigured,null as ActivityId,  
		CT.ProjectTimeZoneName AS ProjectTimeZoneName,ZM.TZoneName AS UserTimeZoneName,  
		TD.OpenDateTime ,2 ,TD.Closeddate AS ClosedDate,TD.CompletedDateTime AS CompletedDate,'T' 
		from [AVL].[TK_TRN_InfraTicketDetail](NOLOCK) TD   
		INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.ProjectID=TD.ProjectID AND LM.UserID =TD.AssignedTo  
		INNER JOIN AVL.CUSTOMER(NOLOCK) C ON LM.CustomerID=C.CustomerID  AND C.IsDeleted = 0
		INNER JOIN [AVL].[InfraTowerProjectMapping](NOLOCK) APM  ON  LM.ProjectID=APM.ProjectID AND TD.TowerID=APM.TowerID  
		INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=LM.CustomerID  and CT.ProjectID=TD.ProjectId  
		LEFT JOIN #TicketedTimesheetdetailsTemp(NOLOCK) TTDTemp ON TD.TimeTickerID=TTDTemp.TimeTickerID  and TTDTemp.[Type] ='T' 
		LEFT JOIN #AutoAssignedTicketTemp(NOLOCK) ATT ON ATT.TimeTickerID=TD.TimeTickerID
		LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) ZM ON LM.TimeZoneId=ZM.TimeZoneID  
		WHERE LM.CustomerID =@CustomerID  and LM.EmployeeID =@EmployeeID  
		AND  CONVERT(DATE,TD.OpenDateTime) <= CONVERT(DATE,@LastDateOfWeek) AND
		Convert(Date,TD.Closeddate) BETWEEN Convert(Date,@FirstDateOfWeek) AND CONVERT(DATE,@LastDateOfWeek)
		AND TD.DARTStatusID=8 
		AND (TD.IsAttributeUpdated=0 OR TD.EffortTillDate=0)
		and TTDTemp.TimeTickerID IS NULL AND ATT.TimeTickerID IS NULL 
		ORDER BY TD.OpenDateTime DESC 

		SELECT  TOP (@CountOftckt)  *  INTO #ClosedTicketWithNoEfforts FROM #ClosedTicketWithNoEffortsAll  
		ORDER BY OpenDateTime DESC


	----------------REMOVE THE AUTOASSIGNED DELETED TICKET----------------
	DELETE AutoAssign FROM #AutoAssignedTicketTemp AutoAssign
	INNER JOIN AVL.AutoAssigneeExclude(NOLOCK) AutoExclude ON AutoAssign.TimeTickerID=AutoExclude.TimeTickerID
	 AND AutoAssign.CustomerID=AutoExclude.CustomerID AND AutoAssign.ProjectID=AutoExclude.ProjectID 
	AND AutoAssign.TicketID=AutoExclude.TicketID  
	INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.CustomerID=AutoAssign.CustomerID AND LM.ProjectID=AutoExclude.ProjectID 
	WHERE AutoExclude.CustomerID=@CustomerID AND AutoExclude.StartDate>=@FirstDateOfWeek 
	AND AutoExclude.EndDate<=@LastDateOfWeek AND AutoAssign.SupportTypeID=1 AND LM.EmployeeID=@EmployeeID

	DELETE AutoAssign FROM #AutoAssignedTicketTemp AutoAssign
	INNER JOIN AVL.AutoAssigneeExcludeInfra(NOLOCK) AutoExclude ON AutoAssign.TimeTickerID=AutoExclude.TimeTickerID
	 AND AutoAssign.CustomerID=AutoExclude.CustomerID AND AutoAssign.ProjectID=AutoExclude.ProjectID 
	AND AutoAssign.TicketID=AutoExclude.TicketID  
	INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.CustomerID=AutoAssign.CustomerID AND LM.ProjectID=AutoExclude.ProjectID 
	WHERE AutoExclude.CustomerID=@CustomerID AND AutoExclude.StartDate>=@FirstDateOfWeek 
	AND AutoExclude.EndDate<=@LastDateOfWeek AND AutoAssign.SupportTypeID=2 AND LM.EmployeeID=@EmployeeID


	SELECT TD.HealingTicketID INTO #DormantTicketList FROM  AVL.DEBT_TRN_HealTicketDetails(NOLOCK) TD
	INNER JOIN AVL.DEBT_PRJ_HealProjectPatternColumnMapping(NOLOCK) HPC ON TD.ProjectPatternMapID=HPC.ProjectPatternColumnMapID
	INNER JOIN #MAS_LoginMaster(NOLOCK) LM ON LM.ProjectID=HPC.ProjectID 
	WHERE LM.CustomerID=@CustomerID AND TD.MarkAsDormant=1 AND ISNULL(TD.IsDeleted,0)=0 AND ISNULL(TD.ManualNonDebt,0) != 1 


	INSERT INTO #EffortEntryDataTemp
	SELECT  TS.TimesheetId, TS.TimesheetDate,TS.TimeSheetDetailId, TS.TimeTickerID,	TS.TicketID,	TS.ApplicationID,	TS.ProjectID,	TS.AssignedTo,
	TS.EffortTillDate,TS.Effort	,TS.ServiceID,	TS.TicketDescription,	TS.IsDeleted,	TS.TicketStatusMapID,TS.TicketTypeMapID, 
	TS.IsSDTicket,		TS.DARTStatusID,	TS.ITSMEffort, TS.IsNonTicket,
	TS.IsCustomer,TS.IsEfforTracked,TS.IsDebtEnabled,TS.IsMainSpringConfigured, TS.ISTicket,TS.ActivityId,
	TS.ProjectTimeZoneName AS ProjectTimeZoneName,TS.UserTimeZoneName AS UserTimeZoneName,TS.TowerID,TS.SupportTypeID,TS.ClosedDate AS ClosedDate,
	TS.CompletedDate,TS.[Type]
	 FROM
	(
	SELECT null AS TimesheetId,null AS TimesheetDate,NULL AS TimeSheetDetailId, TD.TimeTickerID,	TD.TicketID,	TD.ApplicationID,	TD.ProjectID,	TD.AssignedTo,
	TD.EffortTillDate,0 As Effort	,TD.ServiceID,	TD.TicketDescription,	TD.IsDeleted,	TD.TicketStatusMapID,	TD.TicketTypeMapID, 
	TD.IsSDTicket,		TD.DARTStatusID,	TD.ITSMEffort, ATT.IsNonTicket,
	ATT.IsCustomer,ATT.IsEfforTracked,ATT.IsDebtEnabled,ATT.IsMainSpringConfigured,1 as ISTicket, Null as ActivityId,
	ATT.ProjectTimeZoneName AS ProjectTimeZoneName,ATT.UserTimeZoneName AS UserTimeZoneName,NULL AS TowerID,ATT.SupportTypeID,TD.Closeddate AS ClosedDate,
	TD.CompletedDateTime AS CompletedDate,ATT.[Type]
	from  [AVL].[TK_TRN_TicketDetail] (NOLOCK) TD 
	INNER JOIN  #AutoAssignedTicketTemp(NOLOCK) ATT ON ATT.TimeTickerID= TD.TimeTickerID
	LEFT JOIN #DormantTicketList(NOLOCK) Dormant ON TD.TicketID=Dormant.HealingTicketID
	WHERE Dormant.HealingTicketID IS NULL AND ATT.SupportTypeID=1
	
	UNION

	SELECT ATT.TimesheetId AS TimesheetId,ATT.TimesheetDate AS TimesheetDate,ATT.TimeSheetDetailId AS TimeSheetDetailId, TD.WorkItemDetailsId,	TD.WorkItem_Id,	null AS ApplicationID,	TD.Project_Id,	TD.Assignee,
	TD.WorkProfilerEffort as EffortTillDate,ATT.Effort As Effort	,ATT.ServiceID,	TD.WorkItem_Title,	TD.IsDeleted,	TD.StatusMapId,	TD.WorkTypeMapId, 
	null AS IsSDTicket,	TD.StatusMapId AS DARTStatusID,	null AS ITSMEffort, ATT.IsNonTicket,
	ATT.IsCustomer,ATT.IsEfforTracked,ATT.IsDebtEnabled,ATT.IsMainSpringConfigured,1 as ISTicket, ATT.ActivityId as ActivityId,
	ATT.ProjectTimeZoneName AS ProjectTimeZoneName,ATT.UserTimeZoneName AS UserTimeZoneName,NULL AS TowerID,ATT.SupportTypeID,null AS ClosedDate,
	null AS CompletedDate,ATT.[Type]
	from  adm.ALM_TRN_WorkItem_Details (NOLOCK) TD 
	INNER JOIN  #TicketedTimesheetdetailsTemp(NOLOCK) ATT ON ATT.TimeTickerID= TD.WorkItemDetailsId
	--WHERE ATT.SupportTypeID=1
	WHERE ATT.Type = 'W'
	UNION

	Select ATT.TimesheetId,ATT.TimesheetDate,ATT.TimeSheetDetailId,	TD.TimeTickerID,TD.TicketID,	TD.ApplicationID,	TD.ProjectID,	TD.AssignedTo,
	TD.EffortTillDate,ATT.Effort	,ATT.ServiceID,	TD.TicketDescription,	TD.IsDeleted,	TD.TicketStatusMapID,	TD.TicketTypeMapID, 
	TD.IsSDTicket,		TD.DARTStatusID,	TD.ITSMEffort,ATT.IsNonTicket 
	,ATT.IsCustomer,ATT.IsEfforTracked,ATT.IsDebtEnabled,ATT.IsMainSpringConfigured,0 as ISTicket,ATT.ActivityId,
	ATT.ProjectTimeZoneName AS ProjectTimeZoneName,ATT.UserTimeZoneName AS UserTimeZoneName,NULL AS TowerID,SupportTypeID,TD.Closeddate AS ClosedDate,
	TD.CompletedDateTime AS CompletedDate,ATT.[Type]
	from  [AVL].[TK_TRN_TicketDetail] (NOLOCK) TD 
	INNER JOIN  #TicketedTimesheetdetailsTemp(NOLOCK) ATT ON ATT.TimeTickerID= TD.TimeTickerID
	LEFT JOIN #DormantTicketList(NOLOCK) Dormant ON TD.TicketID=Dormant.HealingTicketID
	WHERE Dormant.HealingTicketID IS NULL  AND ATT.SupportTypeID=1

	UNION
	Select TimesheetId,TimesheetDate,TimeSheetDetailId,TimeTickerID,TicketID, NULL AS ApplicationID,	ProjectID AS ProjectID,	AssignedTo AS AssignedTo,
	null AS EffortTillDate ,Effort,Null AS ServiceID,	Activity AS TicketDescription,	0 AS IsDeleted,null AS TicketStatusMapID,	NULL as TicketTypeMapID, 
	Null AS IsSDTicket,		NULL AS DARTStatusID,	NULL AS ITSMEffort ,1 AS IsNonTicket ,
	null AS IsCustomer, null AS IsEfforTracked,null AS IsDebtEnabled,null as  IsMainSpringConfigured ,0 as ISTicket, ActivityId,
	NULL AS ProjectTimeZoneName,NULL AS UserTimeZoneName,NULL AS TowerID, SupportTypeID AS SupportTypeID,NULL AS ClosedDate,
	NULL AS CompletedDate, [Type]
	from   #NonTicketedTimesheetdetailsTemp(NOLOCK) 
	UNION
	 SELECT null AS TimesheetId,null AS TimesheetDate,NULL AS TimeSheetDetailId, TD.TimeTickerID, TD.TicketID, TD.ApplicationID, TD.ProjectID, TD.AssignedTo,  
	 TD.EffortTillDate,0 As Effort ,TD.ServiceID, TD.TicketDescription, TD.IsDeleted, TD.TicketStatusMapID, TD.TicketTypeMapID,   
	 TD.IsSDTicket,  TD.DARTStatusID, TD.ITSMEffort, CTT.IsNonTicket,  
	 CTT.IsCustomer,CTT.IsEfforTracked,CTT.IsDebtEnabled,CTT.IsMainSpringConfigured,1 as ISTicket, Null as ActivityId,  
	 CTT.ProjectTimeZoneName AS ProjectTimeZoneName,CTT.UserTimeZoneName AS UserTimeZoneName ,NULL AS TowerID,CTT.SupportTypeID,TD.Closeddate AS ClosedDate,
	 TD.CompletedDateTime AS CompletedDate,CTT.[Type]
	 FROM
	  [AVL].[TK_TRN_TicketDetail] (NOLOCK) TD   
	 INNER JOIN  #ClosedTicketWithNoEfforts(NOLOCK) CTT ON CTT.TimeTickerID= TD.TimeTickerID  
	 LEFT JOIN #DormantTicketList(NOLOCK) Dormant ON TD.TicketID=Dormant.HealingTicketID  
	 WHERE Dormant.HealingTicketID IS NULL  AND CTT.SupportTypeID=1

	) AS TS

	INSERT INTO #EffortEntryDataTemp
	SELECT  TSInfra.TimesheetId, TSInfra.TimesheetDate,TSInfra.TimeSheetDetailId, TSInfra.TimeTickerID,	TSInfra.TicketID,
		TSInfra.ApplicationID,	TSInfra.ProjectID,	TSInfra.AssignedTo,
	TSInfra.EffortTillDate,TSInfra.Effort	,TSInfra.ServiceID,	TSInfra.TicketDescription,	TSInfra.IsDeleted,	TSInfra.TicketStatusMapID,
	TSInfra.TicketTypeMapID, 
	TSInfra.IsSDTicket,		TSInfra.DARTStatusID,	TSInfra.ITSMEffort, TSInfra.IsNonTicket,
	TSInfra.IsCustomer,TSInfra.IsEfforTracked,TSInfra.IsDebtEnabled,TSInfra.IsMainSpringConfigured, 
	TSInfra.ISTicket,TSInfra.ActivityId,
	TSInfra.ProjectTimeZoneName AS ProjectTimeZoneName,TSInfra.UserTimeZoneName AS UserTimeZoneName ,
	TSInfra.TowerID AS TowerID,TSInfra.SupportTypeID,TSInfra.ClosedDate AS  ClosedDate,
	TSInfra.CompletedDate AS CompletedDate,TSInfra.[Type]
	 FROM
	(
		--Infra
	SELECT null AS TimesheetId,null AS TimesheetDate,NULL AS TimeSheetDetailId, TD.TimeTickerID,	TD.TicketID,	NULL AS ApplicationID,	TD.ProjectID,	TD.AssignedTo,
	TD.EffortTillDate,0 As Effort	,TD.ServiceID,	TD.TicketDescription,	TD.IsDeleted,	TD.TicketStatusMapID,	TD.TicketTypeMapID, 
	TD.IsSDTicket,		TD.DARTStatusID,	TD.ITSMEffort, ATT.IsNonTicket,
	ATT.IsCustomer,ATT.IsEfforTracked,ATT.IsDebtEnabled,ATT.IsMainSpringConfigured,1 as ISTicket, Null as ActivityId,
	ATT.ProjectTimeZoneName AS ProjectTimeZoneName,ATT.UserTimeZoneName AS UserTimeZoneName,TD.TowerID,ATT.SupportTypeID,TD.Closeddate AS ClosedDate,
	TD.CompletedDateTime AS CompletedDate,ATT.[Type]
	from  [AVL].TK_TRN_InfraTicketDetail (NOLOCK) TD 
	INNER JOIN  #AutoAssignedTicketTemp(NOLOCK) ATT ON ATT.TimeTickerID= TD.TimeTickerID
	LEFT JOIN #DormantTicketList Dormant(NOLOCK) ON TD.TicketID=Dormant.HealingTicketID
	WHERE Dormant.HealingTicketID IS NULL AND ATT.SupportTypeID=2
		UNION
	Select ATT.TimesheetId,ATT.TimesheetDate,ATT.TimeSheetDetailId,	TD.TimeTickerID,TD.TicketID,	NULL AS ApplicationID,	TD.ProjectID,	TD.AssignedTo,
	TD.EffortTillDate,ATT.Effort	,ATT.ServiceID,	TD.TicketDescription,	TD.IsDeleted,	TD.TicketStatusMapID,	TD.TicketTypeMapID, 
	TD.IsSDTicket,		TD.DARTStatusID,	TD.ITSMEffort,ATT.IsNonTicket 
	,ATT.IsCustomer,ATT.IsEfforTracked,ATT.IsDebtEnabled,ATT.IsMainSpringConfigured,0 as ISTicket,ATT.ActivityId,
	ATT.ProjectTimeZoneName AS ProjectTimeZoneName,ATT.UserTimeZoneName AS UserTimeZoneName,TD.TowerID,ATT.SupportTypeID,TD.Closeddate AS ClosedDate,
	TD.CompletedDateTime AS CompletedDate,ATT.[Type]
	from  AVL.TK_TRN_InfraTicketDetail (NOLOCK) TD 
	INNER JOIN  #TicketedTimesheetdetailsTemp(NOLOCK) ATT ON ATT.TimeTickerID= TD.TimeTickerID
	LEFT JOIN #DormantTicketList(NOLOCK) Dormant ON TD.TicketID=Dormant.HealingTicketID
	WHERE Dormant.HealingTicketID IS NULL  AND ATT.SupportTypeID=2
	 	UNION
	 SELECT null AS TimesheetId,null AS TimesheetDate,NULL AS TimeSheetDetailId, TD.TimeTickerID, TD.TicketID, NULL AS ApplicationID, TD.ProjectID, TD.AssignedTo,  
	 TD.EffortTillDate,0 As Effort ,TD.ServiceID, TD.TicketDescription, TD.IsDeleted, TD.TicketStatusMapID, TD.TicketTypeMapID,   
	 TD.IsSDTicket,  TD.DARTStatusID, TD.ITSMEffort, CTT.IsNonTicket,  
	 CTT.IsCustomer,CTT.IsEfforTracked,CTT.IsDebtEnabled,CTT.IsMainSpringConfigured,1 as ISTicket, Null as ActivityId,  
	 CTT.ProjectTimeZoneName AS ProjectTimeZoneName,CTT.UserTimeZoneName AS UserTimeZoneName,TD.TowerID,CTT.SupportTypeID ,TD.Closeddate AS ClosedDate,
	 TD.CompletedDateTime AS CompletedDate,CTT.[Type]   FROM
	  [AVL].TK_TRN_InfraTicketDetail (NOLOCK) TD   
	 INNER JOIN  #ClosedTicketWithNoEfforts(NOLOCK) CTT ON CTT.TimeTickerID= TD.TimeTickerID  
	 LEFT JOIN #DormantTicketList Dormant(NOLOCK) ON TD.TicketID=Dormant.HealingTicketID  
	 WHERE Dormant.HealingTicketID IS NULL  AND CTT.SupportTypeID=2
	)AS TSInfra



	SELECT DISTINCT  
	ED.SNO,ED.DATETODAY,TS.TimesheetId,TS.TimesheetDate,TS.ProjectID,TS.TimeSheetDetailId  
	Into #TimesheetandTimesheetdetailsidTemp From   #EffortEntryDataTemp(NOLOCK) TS
	LEFT JOIN #EFFORTDATES(NOLOCK) ED  on Ts.TimesheetDate=ED.DATETODAY

	SELECT TimeTickerID,	TicketID,	ApplicationID,	ProjectID,	AssignedTo,
	EffortTillDate,ServiceID,	TicketDescription,	IsDeleted,	TicketStatusMapID,TicketTypeMapID, 
	IsSDTicket,		DARTStatusID,	ITSMEffort, IsNonTicket,
	IsCustomer,IsEfforTracked,IsDebtEnabled,IsMainSpringConfigured, ISTicket ,ActivityId,
	ProjectTimeZoneName,UserTimeZoneName,[1TimeSheetDetailId],[1],[2TimeSheetDetailId],[2],[3TimeSheetDetailId],[3],
	[4TimeSheetDetailId],[4],[5TimeSheetDetailId],[5],[6TimeSheetDetailId],[6],[7TimeSheetDetailId],[7],
	TowerID,SupportTypeID ,ClosedDate,CompletedDate,[Type]
	INTO #LastTemp FROM   
	(SELECT TimeTickerID,	TicketID,	ApplicationID,	ProjectID,	AssignedTo,
	EffortTillDate,ServiceID,	TicketDescription,	IsDeleted,	TicketStatusMapID,TicketTypeMapID, 
	IsSDTicket,		DARTStatusID,	ITSMEffort, IsNonTicket,
	IsCustomer,IsEfforTracked,IsDebtEnabled,IsMainSpringConfigured, ISTicket ,ActivityId,
	ProjectTimeZoneName,UserTimeZoneName,
	[1TimeSheetDetailId]= CASE WHEN p.[1] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,   
	[1] = CASE WHEN p.[1] IS NULL THEN NULL ELSE p.[1] END,
	[2TimeSheetDetailId]= CASE WHEN p.[2] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,   
	[2] = CASE WHEN p.[2] IS NULL THEN NULL ELSE p.[2] END, 
	[3TimeSheetDetailId]= CASE WHEN p.[3] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,   
	[3] = CASE WHEN p.[3] IS NULL THEN NULL ELSE p.[3] END,  
	[4TimeSheetDetailId]= CASE WHEN p.[4] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,   
	[4] = CASE WHEN p.[4] IS NULL THEN NULL ELSE p.[4] END,  
	[5TimeSheetDetailId]= CASE WHEN p.[5] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,   
	[5] = CASE WHEN p.[5] IS NULL THEN NULL ELSE p.[5] END,  
	[6TimeSheetDetailId]= CASE WHEN p.[6] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,   
	[6] = CASE WHEN p.[6] IS NULL THEN NULL ELSE p.[6] END,  
	[7TimeSheetDetailId]= CASE WHEN p.[7] IS NULL THEN NULL ELSE p.TimeSheetDetailId END,   
	[7] = CASE WHEN p.[7] IS NULL THEN NULL ELSE p.[7] END  ,
	TowerID,SupportTypeID,ClosedDate,CompletedDate,[Type]
	FROM  
	(SELECT   
	ED.SNO,ED.DATETODAY,TS.TimesheetId,TS.TimesheetDate,TS.TimeSheetDetailId, TS.TimeTickerID,	TS.TicketID,	TS.ApplicationID,	
	TS.ProjectID,	TS.AssignedTo,
	TS.EffortTillDate,TS.Effort	,TS.ServiceID,	TS.TicketDescription,	TS.IsDeleted,	TS.TicketStatusMapID,TS.TicketTypeMapID, 
	TS.IsSDTicket,		TS.DARTStatusID,	TS.ITSMEffort, TS.IsNonTicket,
	TS.IsCustomer,TS.IsEfforTracked,TS.IsDebtEnabled,TS.IsMainSpringConfigured, TS.ISTicket,ActivityId,
	TS.ProjectTimeZoneName AS ProjectTimeZoneName,TS.UserTimeZoneName AS UserTimeZoneName,TS.TowerID,TS.SupportTypeID,TS.ClosedDate,
	TS.CompletedDate,TS.[Type]
	FROM  #EffortEntryDataTemp(NOLOCK) TS
	LEFT JOIN #EFFORTDATES(NOLOCK) ED  on Ts.TimesheetDate=ED.DATETODAY) s
	PIVOT(MAX(Effort)
	FOR s.SNO IN ( [1], [2], [3], [4], [5], [6], [7])
	) p 
	)
	AS PVTResult  
	ORDER BY PVTResult.TicketID;		

	

	SELECT DISTINCT TimeTickerID,	TicketID,	ApplicationID,	ProjectID,	AssignedTo,
	EffortTillDate,ServiceID,	TicketDescription,	IsDeleted,	TicketStatusMapID,TicketTypeMapID, 
	IsSDTicket,		DARTStatusID,	ITSMEffort, IsNonTicket,
	IsCustomer,IsEfforTracked,IsDebtEnabled,IsMainSpringConfigured, ISTicket,ActivityId,
	ProjectTimeZoneName AS ProjectTimeZoneName,UserTimeZoneName AS UserTimeZoneName,
	MAX([1TimeSheetDetailId]) AS [1TimeSheetDetailId],max([1]) AS [1],
	MAX([2TimeSheetDetailId]) AS [2TimeSheetDetailId] ,max([2]) AS [2],
	MAX([3TimeSheetDetailId]) AS [3TimeSheetDetailId],max([3]) AS [3] ,
	MAX([4TimeSheetDetailId]) AS [4TimeSheetDetailId],max([4]) AS [4],
	MAX([5TimeSheetDetailId]) AS [5TimeSheetDetailId],max([5]) AS [5] ,
	MAX([6TimeSheetDetailId]) AS [6TimeSheetDetailId],max([6]) AS [6],
	MAX([7TimeSheetDetailId]) AS [7TimeSheetDetailId],max([7]) AS [7],
	TowerID,
	SupportTypeID,
	ClosedDate,
	CompletedDate,
	NULL AS IsAHTagged,[Type]
	INTO #FinalTemp FROM #LastTemp(NOLOCK)
	GROUP BY TimeTickerID,	TicketID,	ApplicationID,	ProjectID,	AssignedTo,
	EffortTillDate,ServiceID,	TicketDescription,	IsDeleted,	TicketStatusMapID,TicketTypeMapID, 
	IsSDTicket,		DARTStatusID,	ITSMEffort, IsNonTicket,
	IsCustomer,IsEfforTracked,IsDebtEnabled,IsMainSpringConfigured, ISTicket,ActivityId,
	ProjectTimeZoneName,UserTimeZoneName,TowerID,SupportTypeID,ClosedDate,CompletedDate,[Type]

	Select T.TicketID,T.ProjectID,T.IsAttributeUpdated 
	INTO #IsAttributeTemp FROM [AVL].[TK_TRN_TicketDetail](NOLOCK) T
	Inner JOIN #FinalTemp(NOLOCK) F ON F.ProjectID=T.ProjectID AND F.TimeTickerID=T.TimeTickerID AND F.TicketID=T.TicketID 

	Select T.TicketID,T.ProjectID,T.IsAttributeUpdated 
	INTO #IsAttributeTempInfra FROM [AVL].TK_TRN_InfraTicketDetail(NOLOCK) T
	Inner JOIN #FinalTemp(NOLOCK) F ON F.ProjectID=T.ProjectID AND F.TimeTickerID=T.TimeTickerID AND F.TicketID=T.TicketID 

	UPDATE FT SET FT.IsAHTagged =1 FROM 
	#FinalTemp FT
	INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPPM ON FT.ProjectID=HPPM.ProjectID
	INNER JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails] (NOLOCK) IHTD ON IHTD.ProjectPatternMapId=HPPM.ProjectPatternMapId
	INNER JOIN AVL.DEBT_PRJ_InfraHealParentChild(NOLOCK) IHPD ON HPPM.ProjectPatternMapId=IHPD.ProjectPatternMapId
	AND FT.TicketID=IHPD.DARTTicketID AND IHPD.MapStatus=1 AND IHTD.HealingTicketID <> '0' AND ISNULL(IHPD.IsDeleted,0) != 1
	AND SupportTypeID =2 

	UPDATE FT SET FT.IsAHTagged =1 FROM 
	#FinalTemp FT 
	INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM ON FT.ProjectID=HPPM.ProjectID
	INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] (NOLOCK) IHTD ON IHTD.ProjectPatternMapId=HPPM.ProjectPatternMapId
	INNER JOIN AVL.DEBT_PRJ_HealParentChild(NOLOCK) HPD ON HPPM.ProjectPatternMapId=HPD.ProjectPatternMapID
	AND FT.TicketID=HPD.DARTTicketID AND HPD.MapStatus=1 AND IHTD.HealingTicketID <> '0'  AND ISNULL(HPD.IsDeleted,0) != 1
	AND SupportTypeID=1

	SELECT DISTINCT FT.TimeTickerID,	FT.TicketID,	FT.ApplicationID,	FT.ProjectID,	FT.AssignedTo,
	FT.EffortTillDate,FT.ServiceID,	FT.TicketDescription,	FT.IsDeleted,	FT.TicketStatusMapID,FT.TicketTypeMapID, 
	FT.IsSDTicket,		FT.DARTStatusID,	FT.ITSMEffort,FT.IsNonTicket,
	FT.IsCustomer,FT.IsEfforTracked,FT.IsDebtEnabled,FT.IsMainSpringConfigured,FT.ISTicket,FT.ActivityId,
	CASE WHEN FT.SupportTypeID =2 THEN  ETDTI.IsAttributeUpdated
	WHEN FT.[Type] ='W' THEN 1
	ELSE ETDT.IsAttributeUpdated END AS IsAttributeUpdated ,
	FT.ProjectTimeZoneName AS ProjectTimeZoneName,FT.UserTimeZoneName AS UserTimeZoneName,
	FT.[1TimeSheetDetailId], FT.[1],
	FT.[2TimeSheetDetailId],  FT.[2],
	FT.[3TimeSheetDetailId], FT.[3] ,
	FT.[4TimeSheetDetailId],   FT.[4],
	FT.[5TimeSheetDetailId], FT.[5] ,
	FT.[6TimeSheetDetailId], FT.[6],
	FT.[7TimeSheetDetailId], FT.[7],
	CASE WHEN FT.SupportTypeID =1 
	THEN CASE WHEN AHT.HealingTicketID IS NOT NULL THEN 1 ELSE 0 END 	
	ELSE CASE WHEN IAHT.HealingTicketID IS NOT NULL THEN 1 ELSE 0 END 
	END AS 'IsAHTicket',
	FT.TowerID,
	FT.SupportTypeID,
	ISNULL(PDB.GracePeriod,365) AS GracePeriod,
	ISNULL(FT.IsAHTagged,0) AS IsAHTagged,
	FT.ClosedDate,
	FT.CompletedDate,
	FT.[Type],
	CASE WHEN  FT.SupportTypeID =1
	Then
	(select Top 1 OpenDateTime from [AVL].[TK_TRN_TicketDetail](NOLOCK) as Tic where Tic.TimeTickerID=FT.TimeTickerID)	
	Else
	(select Top 1 OpenDateTime from [AVL].[TK_TRN_InfraTicketDetail](NOLOCK) as Tic where Tic.TimeTickerID=FT.TimeTickerID)  
	END
	AS OpenDateNTime
	FROM  #FinalTemp(NOLOCK) FT
	LEFT JOIN #IsAttributeTemp(NOLOCK)  ETDT  ON FT.ProjectID=ETDT.ProjectID AND ETDT.TicketID=FT.TicketID 
	LEFT JOIN #IsAttributeTempInfra(NOLOCK) ETDTI  ON FT.ProjectID=ETDTI.ProjectID AND ETDTI.TicketID=FT.TicketID 
	LEFT JOIN [AVL].[DEBT_TRN_HealTicketDetails](NOLOCK) AHT ON FT.TicketID=AHT.HealingTicketID
	LEFT JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails](NOLOCK) IAHT ON FT.TicketID=IAHT.HealingTicketID
	LEFT JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PDB ON FT.ProjectID=PDB.ProjectID AND ISNULL(PDB.IsDeleted,0)=0
	ORDER BY FT.TicketID ASC

	SELECT DISTINCT TTDT.SNO,TTDT.DATETODAY,TTDT.TimesheetId,TTDT.TimesheetDate,TTDT.TimeSheetDetailId,TTDT.ProjectID,
	(CASE WHEN TT.StatusId in(2,3,6) THEN 'True' ELSE 'False'  END) AS FreezStatus  
	from #TimesheetandTimesheetdetailsidTemp(NOLOCK) TTDT
	INNER JOIN #TimesheetTemp(NOLOCK) TT ON  TT.TimesheetDate=TTDT.DATETODAY
	where TTDT.sno IS NOT NULL AND TTDT.ProjectID IS NOT NULL

	SELECT DISTINCT TTDT.SNO,TTDT.DATETODAY,TTDT.TimesheetId,TTDT.TimesheetDate,TTDT.TimeSheetDetailId,TTDT.ProjectID,
	(CASE WHEN TT.StatusId in(2,3,6) THEN 'true' ELSE 'false'  END) AS FreezeStatus  ,TT.StatusId  AS StatusId
	INTO #FreezeStatus from #TimesheetandTimesheetdetailsidTemp(NOLOCK) TTDT
	INNER JOIN #TimesheetTemp(NOLOCK) TT ON TT.TimesheetDate=TTDT.DATETODAY
	where TTDT.sno IS NOT NULL  AND TTDT.ProjectID IS NOT NULL
	ORDER BY TTDT.DATETODAY

	UPDATE ED 
	SET ED.FreezeStatus=FS.FreezeStatus 
	FROM #EFFORTDATES  ED
	INNER JOIN #FreezeStatus(NOLOCK)  FS
	ON FS.DATETODAY=ED.DATETODAY

	UPDATE #EFFORTDATES SET FreezeStatus='false' WHERE ISNULL(FreezeStatus,'')=''

	SET @IsDaily=(SELECT TOP 1 ISNULL(IsDaily,0) FROM #ConfigTemp(NOLOCK))
	IF @IsDaily = 0
		BEGIN
			DECLARE @CheckFreezeStatus NVARCHAR(50);
			SET @CheckFreezeStatus=(SELECT COUNT(SNO) FROM #EFFORTDATES(NOLOCK) WHERE FreezeStatus='true')
			IF @CheckFreezeStatus> 0
				UPDATE #EFFORTDATES SET FreezeStatus='true'
		END

	UPDATE E
	SET E.FreezeStatus='true'
	FROM #EFFORTDATES E
	LEFT JOIN #TimesheetTemp(NOLOCK) TT ON TT.TimesheetDate=E.DATETODAY
	WHERE ISNULL(TT.StatusId,0)=2

	SELECT DISTINCT E.SNO , E.DATETODAY ,E.NAME,
	CONCAT(LEFT(DATENAME(month, E.DATETODAY),3),'  ', DATEPART(DAY,E.DATETODAY),'<br/>',LEFT(E.NAME,3)) AS DisplayDate,
	E.FreezeStatus AS FreezeStatus ,
	ISNULL(TT.StatusId,0) AS StatusId
	FROM #EFFORTDATES(NOLOCK) E
	LEFT JOIN #TimesheetTemp(NOLOCK) TT ON TT.TimesheetDate=E.DATETODAY
	ORDER BY E.DATETODAY

	
IF OBJECT_ID('tempdb..#AutoAssignedTicketTemp', 'U') IS NOT NULL
BEGIN
	DROP TABLE #AutoAssignedTicketTemp
END
IF OBJECT_ID('tempdb..#AutoAssignedTicketTempAll', 'U') IS NOT NULL
BEGIN
	DROP TABLE #AutoAssignedTicketTempAll
END
IF OBJECT_ID('tempdb..#TicketedTimesheetdetailsTemp', 'U') IS NOT NULL
BEGIN
	DROP TABLE #TicketedTimesheetdetailsTemp
END
IF OBJECT_ID('tempdb..#NonTicketedTimesheetdetailsTemp', 'U') IS NOT NULL
BEGIN
	DROP TABLE #NonTicketedTimesheetdetailsTemp
END
IF OBJECT_ID('tempdb..#ConfigTemp', 'U') IS NOT NULL
BEGIN
	DROP TABLE #ConfigTemp
END
IF OBJECT_ID('tempdb..#EFFORTDATES', 'U') IS NOT NULL
BEGIN
	DROP TABLE #EFFORTDATES
END
IF OBJECT_ID('tempdb..#EffortEntryDataTemp', 'U') IS NOT NULL
BEGIN
	DROP TABLE #EffortEntryDataTemp
END
IF OBJECT_ID('tempdb..#LastTemp', 'U') IS NOT NULL
BEGIN
	DROP TABLE #LastTemp
END
IF OBJECT_ID('tempdb..#FinalTemp', 'U') IS NOT NULL
BEGIN
	DROP TABLE #FinalTemp
END
IF OBJECT_ID('tempdb..#TimesheetandTimesheetdetailsidTemp', 'U') IS NOT NULL
BEGIN
	DROP TABLE #TimesheetandTimesheetdetailsidTemp
END
IF OBJECT_ID('tempdb..#UserProjectDetails', 'U') IS NOT NULL
BEGIN
	DROP TABLE #UserProjectDetails
END
IF OBJECT_ID('tempdb..#TimesheetTemp', 'U') IS NOT NULL
BEGIN
	DROP TABLE #TimesheetTemp
END
IF OBJECT_ID('tempdb..#IsAttributeTemp', 'U') IS NOT NULL
BEGIN
	DROP TABLE #IsAttributeTemp
END
IF OBJECT_ID('tempdb..#DormantTicketList', 'U') IS NOT NULL
BEGIN
	DROP TABLE #DormantTicketList
END
IF OBJECT_ID('tempdb..#MAS_LoginMaster', 'U') IS NOT NULL
BEGIN
	DROP TABLE #MAS_LoginMaster
END
IF OBJECT_ID('tempdb..#FreezeStatus', 'U') IS NOT NULL
BEGIN
	DROP TABLE #FreezeStatus
END
IF OBJECT_ID('tempdb..#ClosedTicketWithNoEfforts', 'U') IS NOT NULL
BEGIN
	DROP TABLE #ClosedTicketWithNoEfforts
END
IF OBJECT_ID('tempdb..#ClosedTicketWithNoEffortsAll', 'U') IS NOT NULL
BEGIN
	DROP TABLE #ClosedTicketWithNoEffortsAll
END
IF OBJECT_ID('tempdb..#IsAttributeTempInfra', 'U') IS NOT NULL
BEGIN
	DROP TABLE #IsAttributeTempInfra
END
IF OBJECT_ID('tempdb..#WorkItemTimesheetDetailTemp', 'U') IS NOT NULL
BEGIN
	DROP TABLE #WorkItemTimesheetDetailTemp
END

END TRY 
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[AVL].[GetWeeklyTicketDetails]', @ErrorMessage, @EmployeeID,0
	END CATCH  
END
