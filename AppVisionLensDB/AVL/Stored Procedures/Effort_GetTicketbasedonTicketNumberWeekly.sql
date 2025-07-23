/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[Effort_GetTicketbasedonTicketNumberWeekly] 
@TicketList [Tvp_TicketIDSupportTypeDetails] readonly, 
@ProjectID int,
@CustomerID bigint,
@EmployeeID NVARCHAR(1000)=null ,
@FirstDateOfWeek varchar(30)=null,
@LastDateOfWeek varchar(30)=null
AS
BEGIN
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON;
DECLARE @Servicecount INT
SET @Servicecount=0;

DECLARE @Type CHAR(1);
SET @Type = (SELECT TOP 1 TYPE FROM @TicketList)

CREATE TABLE #UserProjectDetails
    (
      SNO INT IDENTITY(1,1),
      UserID BigINT,
	  ProjectID BigINT
     )

;WITH MYCTE AS
      (
      SELECT UserID,ProjectID FROM [AVL].[MAS_LoginMaster](NOLOCK) WHERE EmployeeID = @EmployeeID and CustomerID=@CustomerID AND IsDeleted=0
      )
      
            INSERT INTO #UserProjectDetails
            SELECT UserID,ProjectID
            FROM    MYCTE 
            OPTION (MAXRECURSION 0)
 IF(@Type = 'T')
	BEGIN
	CREATE TABLE #SelectedTickets
			(
			SNO INT IDENTITY(1,1),
			  TimeTickerID bigint,
			  TicketID nvarchar(100),
			  ProjectID Bigint,
			  SupportTypeID INT
			  )

		;WITH MYCTE AS
			  (
				SELECT CASE WHEN TL.SupportTypeID=2 AND IT.TimeTickerID IS NOT NULL
				 THEN IT.TimeTickerID WHEN TL.SupportTypeID=1 AND TD.TimeTickerID IS NOT NULL THEN TD.TimeTickerID
				END AS 'TimeTickerID'
				
				,
				CASE WHEN TL.SupportTypeID=2 THEN IT.TicketID WHEN TL.SupportTypeID=1 THEN TD.TicketID
				END AS 'TicketID'
				,@ProjectID AS ProjectID,tl.SupportTypeID as SupportTypeID  from 
				@TicketList TL Left join 
				[AVL].[TK_TRN_TicketDetail](NOLOCK) TD on tl.TicketID=TD.TicketID 
				LEFT JOIN AVL.TK_TRN_InfraTicketDetail(NOLOCK) IT ON tl.TicketID=IT.TicketID 
				where   
				 ((TD.TimeTickerID IS NOT NULL AND TD.Projectid=@ProjectID)  OR (IT.TimeTickerID IS NOT NULL AND IT.ProjectID=@ProjectID))
			  )
                    
					INSERT INTO #SelectedTickets
					SELECT  TimeTickerID ,	  TicketID ,  ProjectID ,SupportTypeID
					FROM    MYCTE 
					OPTION (MAXRECURSION 0)
	END
 ELSE
	BEGIN

		CREATE TABLE #SelectedWorkItems
			         (
						SNO INT IDENTITY(1,1),
						WorkItemDetailsId bigint,
			            WorkItemID nvarchar(100),
			            ProjectID Bigint,
				    )
		;WITH MYCTE AS
					(
					SELECT WorkItemDetailsId,WorkItem_Id AS WorkItemID,Project_Id AS ProjectID
					FROM ADM.ALM_TRN_WorkItem_Details(NOLOCK) WD
					JOIN @TicketList WL
					ON  WL.WorkItemID = WD.WorkItem_Id 
					AND WD.Project_Id = @ProjectID AND WD.IsDeleted = 0
					)
					INSERT INTO #SelectedWorkItems
					SELECT  WorkItemDetailsId ,	  WorkItemID ,  ProjectID 
					FROM    MYCTE 
					OPTION (MAXRECURSION 0)
	END



		CREATE TABLE #EFFORTDATES
			(
			SNO INT IDENTITY(1,1),
			  DATETODAY DATE,
			  NAME VARCHAR(50),
			  FreezeStatus NVARCHAR(50)
			 )

		;WITH MYCTE AS
			  (
				SELECT CAST(@FirstDateOfWeek AS DATETIME) DATEVALUE
				UNION ALL
				SELECT  DATEVALUE + 1
				FROM    MYCTE   
				WHERE   DATEVALUE + 1 <= @LastDateOfWeek
			  )
      
					INSERT INTO #EFFORTDATES
					SELECT  CONVERT(DATE,DATEVALUE) AS DATETODAY , DATENAME(W,DATEVALUE) AS NAME,
					'' AS FREEZESTATUS
					FROM    MYCTE 
					OPTION (MAXRECURSION 0)


					SELECT DISTINCT
							C.CustomerId						AS CustomerId,PM.ProjectID,
							ISNULL(CASE WHEN C.IsCognizant='0' THEN 0 ELSE 1 END,1)			AS IsCustomer,
							ISNULL(CASE WHEN C.IsCognizant='0' THEN 0 ELSE 1 END,1)			AS IsCognizant,
							ISNULL(C.IsEffortConfigured,0)		AS IsEfforTracked,
							ISNULL(CASE WHEN PM.IsDebtEnabled='Y' THEN 1 ELSE 0 END,0)			AS IsDebtEnabled,
							ISNULL(CASE WHEN PM.IsMainspringConfigured='Y' THEN 1 ELSE 0 END,0)	AS IsMainSpringConfigured
							,IsDaily,TM.TZoneName AS ProjectTimeZoneName
							 Into #ConfigTemp
							
							FROM AVL.Customer C ( NOLOCK ) 
							INNER JOIN AVL.MAS_ProjectMaster PM ( NOLOCK ) 
							ON C.CustomerID=PM.CustomerID AND PM.Isdeleted = 0
							LEFT JOIN AVL.MAP_ProjectConfig(NOLOCK) PC ON PM.ProjectID=PC.ProjectID
							LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) TM ON ISNULL(PC.TimeZoneId,32)=TM.TimeZoneID
							WHERE C.CustomerID=@CustomerID  AND C.IsDeleted = 0


				Select TimesheetId,TimesheetDate,StatusId INTO #TimesheetTemp FROM AVL.TM_PRJ_Timesheet(NOLOCK) 
					 where TimesheetDate >= @FirstDateOfWeek AND TimesheetDate  <= @LastDateOfWeek AND CustomerID =@CustomerID 
				 AND SubmitterId In(SELECT userid from #UserProjectDetails(NOLOCK))

			CREATE TABLE #AddTicketTemp
			(
			CustomerID BIGINT NOT NULL,
			ProjectID BIGINT  NULL, 
			ApplicationID BIGINT  NULL, 
			TicketID NVARCHAR(100) NULL,
			AssignedTo BIGINT  NULL, 
			TimeTickerID BIGINT  NULL, 
			 IsNonTicket INT NULL,
			IsCustomer INT NULL,
			IsEfforTracked INT NULL,
			IsDebtEnabled INT NULL,
			IsMainSpringConfigured INT NULL,
			 ActivityId BIGINT  NULL, 
			ProjectTimeZoneName NVARCHAR(100) NULL,
			 UserTimeZoneName NVARCHAR(100) NULL,
			TowerID BIGINT  NULL, 
			SupportTypeID INT
			)
			CREATE TABLE #EffortEntryDataTemp
			(
			TimesheetId BIGINT  NULL,
			TimesheetDate DATE NULL,
			TimeSheetDetailId BIGINT  NULL,
			TimeTickerID BIGINT  NULL,
			TicketID NVARCHAR(100) NULL,
			ApplicationID BIGINT  NULL,
			ProjectID BIGINT  NULL,	
			AssignedTo BIGINT  NULL,
			EffortTillDate DECIMAL(25,2) NULL,
			Effort	 DECIMAL(25,2) NULL,
			ServiceID INT NULL,
			TicketDescription NVARCHAR(MAX) NULL,
			IsDeleted INT NULL,	
			TicketStatusMapID BIGINT  NULL,	
			TicketTypeMapID BIGINT  NULL, 
			IsSDTicket INT NULL,	
			DARTStatusID INT NULL,	
			ITSMEffort  DECIMAL(25,2) NULL,
			IsNonTicket INT NULL,
			IsCustomer INT NULL,
			IsEfforTracked INT NULL,
			IsDebtEnabled INT NULL,
			IsMainSpringConfigured INT NULL,
			ISTicket INT NULL,
			ActivityId INT NULL,
			 ProjectTimeZoneName NVARCHAR(100) NULL,
			 UserTimeZoneName NVARCHAR(100) NULL,
			TowerID BIGINT  NULL,
			SupportTypeID INT,
			Closeddate DATETIME NULL,
			CompletedDate DATETIME NULL,
			[Type] VARCHAR(10)
			)
			IF(@Type = 'T')
			BEGIN
			INSERT INTO #AddTicketTemp

			select distinct PM.CustomerID,TD.ProjectID, TD.ApplicationID,TD.TicketID,TD.AssignedTo,TD.TimeTickerID ,0 as IsNonTicket
			,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,CT.IsMainSpringConfigured,null as ActivityId,
			CT.ProjectTimeZoneName AS ProjectTimeZoneName,TM.TZoneName AS UserTimeZoneName,0 AS TowerID,ST.SupportTypeID
			from [AVL].[TK_TRN_TicketDetail](NOLOCK) TD 
			INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.CustomerID=@CustomerID and PM.ProjectID=@ProjectID AND PM.IsDeleted = 0
			INNER JOIN [AVL].[BusinessClusterMapping](NOLOCK)  BCM ON  BCM.CustomerId=@CustomerID
			INNER JOIN [AVL].[APP_MAS_ApplicationDetails](NOLOCK) AD ON AD.SubBusinessClusterMapID=BCM.BusinessClusterMapID
			INNER JOIN [AVL].[APP_MAP_ApplicationProjectMapping](NOLOCK) APM  ON APM.ApplicationID=AD.ApplicationID and APM.ProjectID=PM.ProjectID 
			INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=@CustomerID and CT.ProjectID=TD.ProjectId
			 JOIN #SelectedTickets(NOLOCK) ST ON ST.TimeTickerID=TD.TimeTickerID AND ST.SupportTypeID=1 AND ST.ProjectID=@ProjectID
			LEFT JOIN AVL.MAS_LoginMaster(NOLOCK) LM ON TD.ProjectID=LM.ProjectID AND LM.EmployeeID=@EmployeeID
			LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) TM ON LM.TimeZoneId=TM.TimeZoneID
			WHERE TD.ProjectID = @ProjectID 

			 UNION


			select distinct PM.CustomerID,TD.ProjectID,0 AS 'ApplicationID',TD.TicketID,TD.AssignedTo,TD.TimeTickerID ,0 as IsNonTicket
			,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,CT.IsMainSpringConfigured,null as ActivityId,
			CT.ProjectTimeZoneName AS ProjectTimeZoneName,TM.TZoneName AS UserTimeZoneName, TD.TowerID,st.SupportTypeID
		
			from [AVL].[TK_TRN_InfraTicketDetail](NOLOCK) TD 
			INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.CustomerID=@CustomerID and PM.ProjectID=@ProjectID
			INNER JOIN [AVL].InfraTowerDetailsTransaction(NOLOCK) AD ON AD.InfraTowerTransactionID=TD.TowerID AND AD.IsDeleted=0
			INNER JOIN [AVL].[InfraTowerProjectMapping](NOLOCK) APM  ON APM.TowerID=AD.InfraTowerTransactionID and APM.ProjectID=PM.ProjectID AND APM.IsEnabled=1
			INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=@CustomerID and CT.ProjectID=TD.ProjectId
			INNER JOIN #SelectedTickets(NOLOCK) ST ON ST.TimeTickerID=TD.TimeTickerID AND ST.ProjectID=@ProjectID
			LEFT JOIN AVL.MAS_LoginMaster(NOLOCK) LM ON TD.ProjectID=LM.ProjectID AND LM.EmployeeID=@EmployeeID
			LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) TM ON LM.TimeZoneId=TM.TimeZoneID
			WHERE TD.ProjectID = @ProjectID 
			END
			ELSE
			BEGIN
			INSERT INTO #AddTicketTemp
			select distinct PM.CustomerID,WD.Project_Id, 0 AS ApplicationID,WorkItem_Id,WD.Assignee,WD.WorkItemDetailsId ,0 as IsNonTicket
			,CT.IsCustomer,CT.IsEfforTracked,CT.IsDebtEnabled,CT.IsMainSpringConfigured,null as ActivityId,
			CT.ProjectTimeZoneName AS ProjectTimeZoneName,TM.TZoneName AS UserTimeZoneName,0 AS TowerID,0 AS SupportTypeID
			from ADM.ALM_TRN_WorkItem_Details (NOLOCK) WD 
			INNER JOIN [AVL].[MAS_ProjectMaster](NOLOCK) PM ON PM.CustomerID=@CustomerID and PM.ProjectID=@ProjectID
			INNER JOIN #ConfigTemp(NOLOCK) CT ON CT.CustomerId=@CustomerID and CT.ProjectID=WD.Project_Id
			 JOIN #SelectedWorkItems(NOLOCK) ST ON ST.WorkItemDetailsId=WD.WorkItemDetailsId  AND ST.ProjectID=@ProjectID
			LEFT JOIN AVL.MAS_LoginMaster(NOLOCK) LM ON WD.Project_Id=LM.ProjectID AND LM.EmployeeID=@EmployeeID
			LEFT JOIN AVL.MAS_TimeZoneMaster(NOLOCK) TM ON LM.TimeZoneId=TM.TimeZoneID
			WHERE WD.Project_Id = @ProjectID 
			END

IF(@Type = 'T')
BEGIN
insert into #EffortEntryDataTemp

Select null as TimesheetId, cast(null as date) as TimesheetDate,NULL AS TimeSheetDetailId, TD.TimeTickerID,	TD.TicketID,	TD.ApplicationID,	TD.ProjectID,	TD.AssignedTo,
	TD.EffortTillDate,0 As Effort	,TD.ServiceID,	TD.TicketDescription,	TD.IsDeleted,	TD.TicketStatusMapID,	TD.TicketTypeMapID, 
	 TD.IsSDTicket,		TD.DARTStatusID,	TD.ITSMEffort, ATT.IsNonTicket,
	 ATT.IsCustomer,ATT.IsEfforTracked,ATT.IsDebtEnabled,ATT.IsMainSpringConfigured,1 as ISTicket, Null as ActivityId,
	 ATT.ProjectTimeZoneName AS ProjectTimeZoneName,ATT.UserTimeZoneName AS UserTimeZoneName,0 AS TowerID,SupportTypeID,
	 Closeddate AS ClosedDate,CompletedDateTime AS CompletedDate,@Type
	  FROM
	   [AVL].[TK_TRN_TicketDetail] (NOLOCK) TD 
INNER JOIN  #AddTicketTemp(NOLOCK) ATT ON ATT.TimeTickerID= TD.TimeTickerID  and ATT.SupportTypeID=1
UNION

Select null as TimesheetId, cast(null as date) as TimesheetDate,NULL AS TimeSheetDetailId, TD.TimeTickerID,	TD.TicketID,0 AS ApplicationID,
			TD.ProjectID,	TD.AssignedTo,
			TD.EffortTillDate,0 As Effort	,TD.ServiceID AS ServiceID,	TD.TicketDescription,	TD.IsDeleted,	TD.TicketStatusMapID,	TD.TicketTypeMapID, 
			TD.IsSDTicket,		TD.DARTStatusID,	TD.ITSMEffort, ATT.IsNonTicket,
			ATT.IsCustomer,ATT.IsEfforTracked,ATT.IsDebtEnabled,ATT.IsMainSpringConfigured,1 as ISTicket, Null as ActivityId,
			ATT.ProjectTimeZoneName AS ProjectTimeZoneName,ATT.UserTimeZoneName AS UserTimeZoneName,TD.TowerID,SupportTypeID,
			Closeddate AS ClosedDate,CompletedDateTime AS CompletedDate,@Type
			FROM [AVL].TK_TRN_InfraTicketDetail (NOLOCK) TD 
			INNER JOIN  #AddTicketTemp(NOLOCK) ATT ON ATT.TimeTickerID= TD.TimeTickerID and ATT.SupportTypeID=2
END
ELSE
BEGIN
insert into #EffortEntryDataTemp
Select null as TimesheetId, cast(null as date) as TimesheetDate,NULL AS TimeSheetDetailId, WD.WorkItemDetailsId,	WD.WorkItem_Id,	0 AS ApplicationID,WD.Project_Id,	WD.Assignee,
WD.WorkProfilerEffort  as EffortTillDate,0 As Effort	,WD.ServiceId as ServiceID,	WD.WorkItem_Title,	WD.IsDeleted,	StatusMapId AS TicketStatusMapID,	 0 AS TicketTypeMapID, 
0 as IsSDTicket,		WD.StatusMapId,	0 AS ITSMEffort, ATT.IsNonTicket,
ATT.IsCustomer,ATT.IsEfforTracked,ATT.IsDebtEnabled,ATT.IsMainSpringConfigured,1 as ISTicket, Null as ActivityId,
ATT.ProjectTimeZoneName AS ProjectTimeZoneName,ATT.UserTimeZoneName AS UserTimeZoneName,0 AS TowerID, 0 as SupportTypeID,
WD.Actual_EndDate AS ClosedDate, CAST(NULL AS DATE)  AS CompletedDate,@Type
FROM ADM.ALM_TRN_WorkItem_Details (NOLOCK) WD 
INNER JOIN  #AddTicketTemp(NOLOCK) ATT ON ATT.TimeTickerID= WD.WorkItemDetailsId
END


CREATE TABLE #TimesheetandTimesheetdetailsidTemp
			(
			  SNO INT ,
			  DATETODAY DATE,
			  TimesheetId Bigint,
			  TimesheetDate DATE,
			  ProjectID Bigint,
			  TimeSheetDetailId Bigint
			 )

INSERT Into #TimesheetandTimesheetdetailsidTemp
SELECT DISTINCT  
	 ED.SNO,ED.DATETODAY,TS.TimesheetId,TS.TimesheetDate ,TS.ProjectID,TS.TimeSheetDetailId   From  #EFFORTDATES(NOLOCK) ED
	  LEFT JOIN #EffortEntryDataTemp(NOLOCK) TS   on TS.TimesheetDate=ED.DATETODAY

SELECT PVTResult.* INTO #LastTemp From   
(SELECT TimeTickerID,	TicketID,	ApplicationID,	ProjectID,	AssignedTo,TowerID,
	EffortTillDate,ServiceID,	TicketDescription,	IsDeleted,	TicketStatusMapID,TicketTypeMapID, 
	IsSDTicket,		DARTStatusID,	ITSMEffort, IsNonTicket,
	IsCustomer,IsEfforTracked,IsDebtEnabled,IsMainSpringConfigured, ISTicket ,ActivityId,
	ProjectTimeZoneName,
	UserTimeZoneName,
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
        [7] = CASE WHEN p.[7] IS NULL THEN NULL ELSE p.[7] END  
		,SupportTypeID
		,Closeddate,
		CompletedDate,
		[Type]
	
FROM  (SELECT   
	 ED.SNO,ED.DATETODAY,TS.TimesheetId,TS.TimesheetDate,TS.TimeSheetDetailId, TS.TimeTickerID,	TS.TicketID,	TS.ApplicationID,	TS.ProjectID,	TS.AssignedTo,TS.TowerID,
	TS.EffortTillDate,TS.Effort	,TS.ServiceID,	TS.TicketDescription,	TS.IsDeleted,	TS.TicketStatusMapID,TS.TicketTypeMapID, 
	 TS.IsSDTicket,		TS.DARTStatusID,	TS.ITSMEffort, TS.IsNonTicket,
	 TS.IsCustomer,TS.IsEfforTracked,TS.IsDebtEnabled,TS.IsMainSpringConfigured, TS.ISTicket,ActivityId,ProjectTimeZoneName,
	UserTimeZoneName,SupportTypeID,Closeddate,CompletedDate,[Type] FROM  #EffortEntryDataTemp(NOLOCK) TS
	  LEFT JOIN #EFFORTDATES(NOLOCK) ED  on Ts.TimesheetDate=ED.DATETODAY) s
 PIVOT(MAX(Effort)
	  FOR s.SNO IN ( [1], [2], [3], [4], [5], [6], [7]) ) p 
	  )
	  as PVTResult  

ORDER BY PVTResult.TicketID;

		
	select distinct TimeTickerID,	TicketID,	ApplicationID,	ProjectID,	AssignedTo,TowerID,
	EffortTillDate,ServiceID,	TicketDescription,	IsDeleted,	TicketStatusMapID,TicketTypeMapID, 
	IsSDTicket,		DARTStatusID,	ITSMEffort, IsNonTicket,
	IsCustomer,IsEfforTracked,IsDebtEnabled,IsMainSpringConfigured, ISTicket,ActivityId,
	ProjectTimeZoneName,
	UserTimeZoneName,
	max([1TimeSheetDetailId]) AS [1TimeSheetDetailId],max([1]) AS [1],
	max([2TimeSheetDetailId]) AS [2TimeSheetDetailId],max([2]) AS [2],
	max([3TimeSheetDetailId]) AS [3TimeSheetDetailId],max([3]) AS [3],
	max([4TimeSheetDetailId]) AS [4TimeSheetDetailId],max([4]) AS [4],
	max([5TimeSheetDetailId]) AS [5TimeSheetDetailId],max([5]) AS [5],
	max([6TimeSheetDetailId]) AS [6TimeSheetDetailId],max([6]) AS [6],
	max([7TimeSheetDetailId]) AS [7TimeSheetDetailId],max([7]) AS [7],
	SupportTypeID,
	Closeddate,
	CompletedDate,
	NULL AS IsAHTagged,
	[Type]
	Into #FinalTemp from #LastTemp(NOLOCK)
	GROUP BY TimeTickerID,	TicketID,	ApplicationID,	ProjectID,	AssignedTo,TowerID,
	EffortTillDate,ServiceID,	TicketDescription,	IsDeleted,	TicketStatusMapID,TicketTypeMapID, 
	IsSDTicket,		DARTStatusID,	ITSMEffort, IsNonTicket,
	IsCustomer,IsEfforTracked,IsDebtEnabled,IsMainSpringConfigured, ISTicket,ActivityId,
	ProjectTimeZoneName,
	UserTimeZoneName,SupportTypeID,Closeddate,CompletedDate,[Type]
			
CREATE TABLE #IsAttributeTemp
(
TicketID NVARCHAR(100)
,ProjectID BIGINT,
IsAttributeUpdated INT,
SupportTypeID INT
)

insert INTO #IsAttributeTemp

Select T.TicketID,T.ProjectID,T.IsAttributeUpdated , F.SupportTypeID from [AVL].[TK_TRN_TicketDetail](NOLOCK) T
Inner JOIN #FinalTemp(NOLOCK) F ON F.TicketID=T.TicketID and F.ProjectID=T.ProjectID and F.SupportTypeID=1

UNION
SELECT T.TicketID,T.ProjectID,T.IsAttributeUpdated ,F.SupportTypeID FROM 
AVL.TK_TRN_InfraTicketDetail(NOLOCK) T
Inner JOIN #FinalTemp F ON F.TicketID=T.TicketID and F.ProjectID=T.ProjectID and F.SupportTypeID=2

   UPDATE FT SET FT.IsAHTagged =1 FROM 
	#FinalTemp FT 
	INNER JOIN [AVL].[DEBT_PRJ_InfraHealProjectPatternMappingDynamic] (NOLOCK) HPPM ON FT.ProjectID=HPPM.ProjectID
    INNER JOIN [AVL].[DEBT_TRN_InfraHealTicketDetails] (NOLOCK) IHTD ON IHTD.ProjectPatternMapId=HPPM.ProjectPatternMapId
    INNER JOIN AVL.DEBT_PRJ_InfraHealParentChild(NOLOCK) IHPD ON HPPM.ProjectPatternMapId=IHPD.ProjectPatternMapId
	AND FT.TicketID=IHPD.DARTTicketID AND IHPD.MapStatus=1 AND IHTD.HealingTicketID <> '0' AND ISNULL(IHPD.IsDeleted,0) != 1
	AND FT.SupportTypeID=2
	
	UPDATE FT SET FT.IsAHTagged =1 FROM 
	#FinalTemp FT 
	INNER JOIN [AVL].[DEBT_PRJ_HealProjectPatternMappingDynamic] (NOLOCK) HPPM ON FT.ProjectID=HPPM.ProjectID
    INNER JOIN [AVL].[DEBT_TRN_HealTicketDetails] (NOLOCK) IHTD ON IHTD.ProjectPatternMapId=HPPM.ProjectPatternMapId
    INNER JOIN AVL.DEBT_PRJ_HealParentChild(NOLOCK) HPD ON HPPM.ProjectPatternMapId=HPD.ProjectPatternMapId
	AND FT.TicketID=HPD.DARTTicketID AND HPD.MapStatus=1 AND IHTD.HealingTicketID <> '0' AND ISNULL(HPD.IsDeleted,0) != 1
	AND FT.SupportTypeID=1




Select  FT.TimeTickerID,	FT.TicketID,	FT.ApplicationID,	FT.ProjectID,	FT.AssignedTo,FT.TowerID,
	FT.EffortTillDate,FT.ServiceID,	FT.TicketDescription,	FT.IsDeleted,	FT.TicketStatusMapID,FT.TicketTypeMapID, 
	FT.IsSDTicket,		FT.DARTStatusID,	FT.ITSMEffort,FT.IsNonTicket,
	FT.IsCustomer,FT.IsEfforTracked,FT.IsDebtEnabled,FT.IsMainSpringConfigured,FT.ISTicket,FT.ActivityId,CASE WHEN ft.[Type]= 'W' THEN 1 
	ELSE ETDT.IsAttributeUpdated END AS IsAttributeUpdated,
	ProjectTimeZoneName,
	UserTimeZoneName,
	FT.[1TimeSheetDetailId], FT.[1],
	FT.[2TimeSheetDetailId],  FT.[2],
	FT.[3TimeSheetDetailId], FT.[3] ,
	FT.[4TimeSheetDetailId],   FT.[4],
	FT.[5TimeSheetDetailId], FT.[5] ,
	FT.[6TimeSheetDetailId], FT.[6],
	FT.[7TimeSheetDetailId], FT.[7],

	CASE WHEN   FT.SupportTypeID =1  Then  
 IIF((SELECT COUNT(HealingTicketID) FROM [AVL].[DEBT_TRN_HealTicketDetails](NOLOCK) WHERE HealingTicketID=FT.TicketID     
 AND Isdeleted<>1)>0,1,0)  
 ELSE  
IIF((SELECT COUNT(HealingTicketID) FROM [AVL].[DEBT_TRN_InfraHealTicketDetails](NOLOCK) WHERE HealingTicketID=FT.TicketID     
 AND Isdeleted<>1)>0,1,0)  
  END AS 'IsAHTicket' ,
	ft.SupportTypeID,
	ISNULL(PDB.GracePeriod,365) AS GracePeriod,
	ISNULL(FT.IsAHTagged,0) as IsAHTagged,
	FT.ClosedDate AS ClosedDate,
	FT.CompletedDate AS CompletedDate,
	FT.[Type],
	CASE WHEN  FT.SupportTypeID =1
	Then
	(select Top 1 OpenDateTime from [AVL].[TK_TRN_TicketDetail] as Tic where Tic.TimeTickerID=FT.TimeTickerID)	
	Else
	(select Top 1 OpenDateTime from [AVL].[TK_TRN_InfraTicketDetail] as Tic where Tic.TimeTickerID=FT.TimeTickerID)  
	END
	AS OpenDateNTime
	from #FinalTemp(NOLOCK) FT
	LEFT JOIn #IsAttributeTemp(NOLOCK)  ETDT  ON ETDT.TicketID=FT.TicketID and FT.ProjectID=ETDT.ProjectID 
	AND FT.SupportTypeID=ETDT.SupportTypeID
	LEFT JOIN AVL.MAS_ProjectDebtDetails(NOLOCK) PDB ON FT.ProjectID=PDB.ProjectID AND ISNULL(PDB.IsDeleted,0)=0

	select distinct TTDT.SNO,TTDT.DATETODAY,TTDT.TimesheetId,TTDT.TimesheetDate,TTDT.TimeSheetDetailId,TTDT.ProjectID,
	(CASE WHEN TT.StatusId in(2,3,6) THEN 'true' ELSE 'false'  END) AS FreezStatus  from #TimesheetandTimesheetdetailsidTemp(NOLOCK) TTDT
INNER JOIN #TimesheetTemp(NOLOCK) TT ON TT.TimesheetDate=TTDT.DATETODAY
	where TTDT.sno is not null and TTDT.ProjectID is not null

	select distinct TTDT.SNO,TTDT.DATETODAY,TTDT.TimesheetId,TTDT.TimesheetDate,TTDT.TimeSheetDetailId,TTDT.ProjectID,
	(CASE WHEN TT.StatusId in(2,3,6) THEN 'true' ELSE 'false'  END) AS FreezeStatus  
    INTO #FreezeStatus from #TimesheetandTimesheetdetailsidTemp(NOLOCK) TTDT
	INNER JOIN #TimesheetTemp(NOLOCK) TT ON TT.TimesheetDate=TTDT.DATETODAY
	where TTDT.sno is not null and TTDT.ProjectID is not null
	
	UPDATE ED 
	SET ED.FreezeStatus=FS.FreezeStatus 
	FROM #EFFORTDATES  ED
	INNER JOIN #FreezeStatus(NOLOCK)  FS
	ON FS.DATETODAY=ED.DATETODAY
	UPDATE #FreezeStatus SET FreezeStatus='false' WHERE FreezeStatus=''

	DECLARE @IsDaily INT;
	SET @IsDaily=(SELECT TOP 1 IsDaily FROM #ConfigTemp(NOLOCK))
	IF @IsDaily = 0
	BEGIN
		DECLARE @CheckFreezeStatus NVARCHAR(50);
		SET @CheckFreezeStatus=(SELECT COUNT(*) FROM #EFFORTDATES(NOLOCK) WHERE FreezeStatus='true')
		if @CheckFreezeStatus> 0
		update #EFFORTDATES set FreezeStatus='true'
	END

	UPDATE E
	SET E.FreezeStatus='true'
	from #EFFORTDATES E
	LEFT JOIN #TimesheetTemp(NOLOCK) TT ON TT.TimesheetDate=E.DATETODAY
	WHERE ISNULL(TT.StatusId,0) IN (2,3,6)


	select distinct E.SNO , E.DATETODAY ,  E.NAME,
   CONCAT(LEFT(DATENAME(month, E.DATETODAY),3),' ', DATEPART(DAY,E.DATETODAY),'<br/>',LEFT(E.NAME,3)) AS DisplayDate,
	E.FreezeStatus AS FreezeStatus ,
	ISNULL(TT.StatusId,0) AS StatusId
	from #EFFORTDATES(NOLOCK) E
	LEFT JOIN #TimesheetTemp(NOLOCK) TT ON TT.TimesheetDate=E.DATETODAY
	

	IF OBJECT_ID('tempdb..#AddTicketTemp', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #AddTicketTemp
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
	IF OBJECT_ID('tempdb..#LastTemp', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #LastTemp
	END
	IF OBJECT_ID('tempdb..#TimesheetandTimesheetdetailsidTemp', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #TimesheetandTimesheetdetailsidTemp
	END
	IF OBJECT_ID('tempdb..#TimesheetTemp', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #TimesheetTemp
	END	
	IF OBJECT_ID('tempdb..#IsAttributeTemp', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #IsAttributeTemp
	END
	IF OBJECT_ID('tempdb..#UserProjectDetails', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #UserProjectDetails
	END
	IF OBJECT_ID('tempdb..#FreezeStatus', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #FreezeStatus
	END	
	IF OBJECT_ID('tempdb..#SelectedTickets', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #SelectedTickets
	END
	IF OBJECT_ID('tempdb..#SelectedWorkItems', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #SelectedWorkItems
	END	



SET NOCOUNT OFF;
COMMIT TRAN
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Effort_GetTicketbasedonTicketNumberWeekly]', @ErrorMessage, @ProjectID,0
		
	END CATCH  
END
