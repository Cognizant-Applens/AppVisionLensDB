/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[TimesheetSubmitAuto]

@tickersession as [avl].[tvp_savetimesheetdetails] READONLY,
@mode VARCHAR(100)

AS
BEGIN
BEGIN TRY
--begin tran
	SET NOCOUNT ON;  
	DECLARE  @timesheeteffortmini AS TABLE
	(
	[sessionid] [BIGINT]  NOT NULL,
	[userid] [BIGINT] NULL,
	[projectid] [BIGINT] NULL,
	[ticketid] [NVARCHAR](100) NULL,
	[ticketdesc] [NVARCHAR](MAX) NULL,
	[ticketopendate] [DATETIME] NULL,
	[applicationid] [BIGINT] NULL,
	[serviceid] [INT] NULL,
	[activityid] [INT] NULL, 
	[tickettypemapid] [BIGINT] NULL,
	[prioritymapid] [BIGINT] NULL,
	[ticketstatusmapid] [BIGINT] NULL,
	[starttime] [DATETIME] NULL,
	[endtime] [DATETIME] NULL,
	[isauto] [BIT] NULL,
	[hours] [INT] NULL,
	[minutes] [INT] NULL,
	[seconds] [INT] NULL,
	[isprocessed] [INT] NULL,
	[employeeid] [NVARCHAR](50) NULL,
	[requestsource] [INT] NULL,
	[issdticket] [BIT] NULL,
	[isnondelivery] [BIT] NULL,
	[nondeliveryactivitytype] [INT] NULL,
	[isdeleted] [BIT] NULL,
	[createdon] [DATETIME] NULL,
	[createdby] [NVARCHAR](50) NULL,
	[modifiedon] [DATETIME] NULL,
	[modifiedby] [NVARCHAR](50) NULL,
	[timetickerid] [bigint] null,
	[isrunning] [BIT] NULL,
	[nonticketdescription] [NVARCHAR](250) NULL,  
	[usercreatedtimedate] [DATETIME] NULL,
	efforts DECIMAL(7,4) NULL,
	[SuggestedActivity] [nvarchar](250) NULL,  
	[Type] [nvarchar](10) NULL
	)
	INSERT INTO @timesheeteffortmini
	SELECT * FROM @tickersession

	CREATE TABLE #timesheettickets
	(
	sno INT IDENTITY(1,1),
	ticketid NVARCHAR(100),
	projectid BIGINT,
	userid BIGINT,
	applicationid BIGINT,
	serviceid BIGINT,
	activityid BIGINT,
	tickettypemapid BIGINT,
	starttime DATETIME,
	endtime DATETIME,
	employeeid NVARCHAR(50),
	isnondelivery BIT,
	timetickerid BIGINT,
	nonticketdescription NVARCHAR(250),
	totaleffort DECIMAL(8,2),
	customerid BIGINT,
	timesheetid BIGINT,
	sessionid BIGINT,
	usercreatedtimedate DATETIME,
	iscognizant INT NULL,
	[SuggestedActivity] [nvarchar](250) NULL,
	Remarks [NVARCHAR](250) NULL,  
	TowerID BIGINT,
	[Type] [nvarchar](10) NULL	
	)

	CREATE TABLE #finalsessions
	(
	sno INT IDENTITY(1,1),
	sessionid BIGINT, 
	projectid BIGINT, 
	ticketid NVARCHAR(100),
	employeeid NVARCHAR(50),
	userid BIGINT,
	totalseconds INT,
	isnondelivery INT,
	timesheetdate DATETIME,
	[SuggestedActivity] [nvarchar](250) NULL,
	[Type] [nvarchar](10) NULL,
	activityid BIGINT NULL
	)
	CREATE TABLE #totalsessions
	(
	sessionid BIGINT NULL,
	projectid BIGINT NULL,
	ticketid NVARCHAR(100) NULL,
	employeeid NVARCHAR(50) NULL,
	userid  BIGINT NULL,
	totalseconds BIGINT NULL,
	isnondelivery BIT NULL,
	timesheetdate DATETIME NULL,
	[SuggestedActivity] [nvarchar](250) NULL,
	[Type] [nvarchar](10) NULL,
	activityid BIGINT NULL
	)

	--step 1 getting the cognizant sessions for past 2 days that are not processed
	INSERT INTO #totalsessions 
		SELECT ms.sessionid, ms.projectid,ms.ticketid,ms.employeeid,ms.userid,
		CASE WHEN @mode='Mini'
		THEN ((ISNULL(ms.[hours],0)*3600)+ (ISNULL(ms.[minutes],0)*60)+ISNULL(ms.[seconds],0)) 
		ELSE ISNULL(ms.efforts,0) 
		END AS totalseconds,
		ms.isnondelivery as isnondelivery,ms.usercreatedtimedate as timesheetdate,SuggestedActivity,ms.[Type],ms.activityid
		FROM @timesheeteffortmini ms
		JOIN avl.mas_projectmaster(NOLOCK) pm on ms.projectid=pm.projectid 
		INNER JOIN avl.customer(NOLOCK) c on pm.customerid=c.customerid
		WHERE ms.isdeleted=0 
		AND ISNULL(ms.serviceid,0)>0 AND ISNULL(ms.activityid,0)>0
		AND ISNULL(ms.projectid,0)>0 
		AND c.iscognizant=1
		AND ISNULL(ms.isdeleted,0)=0 AND ISNULL(ms.isprocessed,0) in(0,2)
		AND ISNULL(c.isefforttrackactivitywise,1)=1


	/*********************Update ServiceClassificationMode*****************************/
	UPDATE TD 
		SET TD.ServiceClassificationMode = 
		CASE  
			WHEN TD.ServiceClassificationMode = 3 THEN 4 
			WHEN TD.ServiceClassificationMode = 4 
				or TD.ServiceClassificationMode = 6  THEN TD.ServiceClassificationMode
			WHEN TD.ServiceClassificationMode = 5 THEN 6                      
        END 
	FROM @tickersession ITD
	JOIN avl.TK_TRN_TicketDetail TD
	ON  ITD.ProjectID = TD.ProjectID 
	AND ITD.TicketID = TD.TicketID
		AND TD.ServiceID <> ITD.ServiceID
	WHERE TD.IsDeleted = 0	
	AND ISNULL(ITD.ServiceID,0) <> 0

	------------------------------------------------------------------------------------
	INSERT INTO #totalsessions 
	SELECT ms.sessionid, ms.projectid,ms.ticketid,ms.employeeid,ms.userid,
	CASE WHEN @mode='Mini'
	THEN ((ISNULL(ms.[hours],0)*3600)+ (ISNULL(ms.[minutes],0)*60)+ISNULL(ms.[seconds],0)) 
	--else ISNULL(ms.efforts,0)*3600 
	ELSE ISNULL(ms.efforts,0)
	END AS totalseconds,
	ms.isnondelivery as isnondelivery,ms.usercreatedtimedate as timesheetdate,SuggestedActivity,ms.[Type],ms.activityid
	FROM @timesheeteffortmini ms
	join avl.mas_projectmaster(nolock) pm on ms.projectid=pm.projectid 
	inner join avl.customer(nolock) c on pm.customerid=c.customerid
	WHERE ms.isdeleted=0 
	AND ISNULL(ms.serviceid,0)>0 
	AND ISNULL(ms.projectid,0)>0 
	AND c.iscognizant=1
	AND ISNULL(ms.isdeleted,0)=0 AND ISNULL(ms.isprocessed,0) in(0,2)
	AND ISNULL(c.isefforttrackactivitywise,1)=0

	---infra
	IF EXISTS(SELECT 1 FROM @timesheeteffortmini where [Type]='I') and @mode ='EffortBulkUpload'
	BEGIN
		INSERT INTO #totalsessions 
		SELECT ms.sessionid, ms.projectid,ms.ticketid,ms.employeeid,ms.userid,
		CASE WHEN @mode='Mini'
		THEN ((ISNULL(ms.[hours],0)*3600)+ (ISNULL(ms.[minutes],0)*60)+ISNULL(ms.[seconds],0)) 
		--else ISNULL(ms.efforts,0)*3600 
		ELSE ISNULL(ms.efforts,0)
		END AS totalseconds,
		ms.isnondelivery as isnondelivery,ms.usercreatedtimedate as timesheetdate,SuggestedActivity,ms.[Type],ms.activityid
		FROM @timesheeteffortmini ms
		join avl.mas_projectmaster(nolock) pm on ms.projectid=pm.projectid 
		inner join avl.customer(nolock) c on pm.customerid=c.customerid
		WHERE ms.isdeleted=0 
		--AND ISNULL(ms.serviceid,0)>0 
		AND ISNULL(ms.projectid,0)>0 
		AND c.iscognizant=1
		AND ISNULL(ms.isdeleted,0)=0 AND ISNULL(ms.isprocessed,0) in(0,2)
		--AND ISNULL(c.isefforttrackactivitywise,1)=0
	END
	
	--step 2 getting the customer sessions for past 2 days that are not processed
	SELECT ms.sessionid, ms.projectid,ms.ticketid,ms.employeeid,ms.userid, 
	CASE WHEN @mode='Mini'
	THEN ((ISNULL(ms.[hours],0)*3600)+ (ISNULL(ms.[minutes],0)*60)+ISNULL(ms.[seconds],0)) 
	ELSE ISNULL(ms.efforts,0)
	END AS totalseconds,
	ms.isnondelivery ,ms.usercreatedtimedate as timesheetdate,SuggestedActivity,ms.[Type],ms.activityid
	INTO #totalsessionscustomer
	FROM @timesheeteffortmini ms
	JOIN avl.mas_projectmaster(nolock) pm on ms.projectid=pm.projectid 
	INNER JOIN avl.customer(nolock) c on pm.customerid=c.customerid
	WHERE ms.isdeleted=0 
	AND ISNULL(ms.tickettypemapid,0)>0		
	AND ISNULL(ms.projectid,0)>0 
	AND c.iscognizant=0
	AND ISNULL(ms.isdeleted,0)=0 AND ISNULL(ms.isprocessed,0) in(0,2)


	--step 3 getting the non delivery sessions for past 2 days that are not processed
	SELECT ms.sessionid, ms.projectid,ms.ticketid,ms.employeeid,ms.userid, 
	CASE WHEN @mode='Mini' 
	THEN ((ISNULL(ms.[hours],0)*3600)+ (ISNULL(ms.[minutes],0)*60)+ISNULL(ms.[seconds],0)) 
	ELSE ISNULL(ms.efforts,0)
	END AS totalseconds,
	ms.isnondelivery ,ms.usercreatedtimedate as timesheetdate,SuggestedActivity,ms.[Type],ms.activityid
	INTO #totalsessionsnondelivery
	FROM @timesheeteffortmini ms
	join avl.mas_projectmaster(nolock) pm on ms.projectid=pm.projectid 
	inner join avl.customer(nolock) c on pm.customerid=c.customerid
	WHERE ms.isdeleted=0 	
	AND ISNULL(ms.projectid,0)>0 
	AND ms.isnondelivery=1 AND ms.nondeliveryactivitytype >0
	AND ISNULL(ms.isdeleted,0)=0 AND ISNULL(ms.isprocessed,0) in(0,2)

	--step 4 :inserting overall sessions
	INSERT INTO #finalsessions
		SELECT sessionid, projectid,ticketid,employeeid,userid,totalseconds,isnondelivery, timesheetdate, SuggestedActivity,[Type],activityid
		FROM #totalsessions (NOLOCK) 
		UNION ALL 
		SELECT sessionid, projectid,ticketid,employeeid,userid,totalseconds,isnondelivery, timesheetdate, SuggestedActivity,[Type],activityid
		FROM #totalsessionscustomer (NOLOCK) 
		UNION
		SELECT sessionid, projectid,ticketid,employeeid,userid,totalseconds,isnondelivery, timesheetdate, SuggestedActivity,[Type],activityid
		FROM #totalsessionsnondelivery (NOLOCK) 


	CREATE TABLE #groupedtickets
	(
	ProjectID BIGINT NULL,
	ticketid NVARCHAR(100) NULL,
	employeeid NVARCHAR(50) NULL,
	userid BIGINT NULL,
	totaleffortseconds BIGINT NULL,
	sessionid BIGINT NULL,
	isnondelivery INT NULL,
	timesheetdate DATE NULL,
	[SuggestedActivity] [nvarchar](50) NULL,
	[Type] [nvarchar](10) NULL,
	activityid BIGINT NULL
	)

	--step 5 grouping AND find sum
	INSERT into #groupedtickets
	SELECT DISTINCT projectid,ticketid,employeeid,userid, ISNULL(totalseconds,0) as totaleffortseconds,
	sessionid ,isnondelivery, timesheetdate, SuggestedActivity,[Type],activityid
	FROM #finalsessions(NOLOCK) 

	IF EXISTS( SELECT DISTINCT projectid FROM #groupedtickets(NOLOCK))

	BEGIN
	--step 6 inserting the session tickets 
	INSERT INTO #timesheettickets(ticketid,projectid,userid,employeeid,sessionid,SuggestedActivity,[Type],activityid)
	SELECT ticketid,projectid,userid,employeeid,sessionid,SuggestedActivity,[Type],activityid FROM #groupedtickets		

	--step 7 updating the details 
	UPDATE tst  set tst.isnondelivery=ISNULL(ms.isnondelivery,0),
	tst.serviceid=ms.serviceid,tst.activityid=ms.activityid,
	tst.usercreatedtimedate=ms.usercreatedtimedate,tst.tickettypemapid=ms.tickettypemapid
	FROM #timesheettickets(NOLOCK) tst
	join @timesheeteffortmini ms on tst.sessionid=ms.sessionid AND tst.projectid =ms.projectid

	--step 8 logic to filter out only the valid tickets FROM the session details table
	UPDATE ts set ts.timetickerid= td.timetickerid,ts.applicationid=td.applicationid,
	ts.tickettypemapid=td.tickettypemapid
	FROM  #timesheettickets(NOLOCK) ts
	inner join avl.tk_trn_ticketdetail(NOLOCK) td
	ON ts.projectid=td.projectid AND ts.ticketid=td.ticketid AND ISNULL(ts.isnondelivery,0)=0
	where ts.[Type] ='T'

    --Infra
	UPDATE ts set ts.timetickerid= td.timetickerid,ts.TowerID=td.TowerID,
	ts.tickettypemapid=td.tickettypemapid,ts.projectid= td.projectid
	FROM  #timesheettickets ts
	inner join avl.TK_TRN_infraTicketDetail td
	ON ts.projectid=td.projectid AND ts.ticketid=td.ticketid
	where ts.[Type] ='I'

	UPDATE ts set ts.timetickerid= WID.WorkItemDetailsId,ts.tickettypemapid=WID.WorkTypeMapId
	FROM  #timesheettickets ts
	inner join ADM.ALM_TRN_WorkItem_Details(nolock) WID
	ON ts.projectid=WID.Project_Id AND ts.ticketid=WID.WorkItem_Id AND ISNULL(ts.isnondelivery,0)=0
	where ts.[Type] ='W'

	IF @Mode !='Mini'
	BEGIN
			UPDATE ts set ts.tickettypemapid=td.tickettypemapid
	FROM  #timesheettickets ts
	inner join avl.tk_trn_ticketdetail(NOLOCK) td
	ON ts.projectid=td.projectid AND ts.ticketid=td.ticketid AND ISNULL(ts.isnondelivery,0)=0
	END


	UPDATE ms set ms.isprocessed=2 
	FROM @timesheeteffortmini ms
	INNER JOIN #timesheettickets(NOLOCK) tt
	on ms.sessionid=tt.sessionid where tt.isnondelivery=0 
	AND (ISNULL(tt.timetickerid,0)=0 or ISNULL(tt.tickettypemapid,0)=0)   	

	DELETE FROM #timesheettickets WHERE ISNULL(isnondelivery,0)=0 AND Type<>'I'
	AND (ISNULL(timetickerid,0)=0 or ISNULL(tickettypemapid,0)=0)  
	
	UPDATE tst  set tst.totaleffort= 
	CASE WHEN @mode='Mini' 
		THEN  cast(round(ms.totaleffortseconds/3600+((((ms.totaleffortseconds%3600)/60.00)/60.00)),2)as numeric(8,2))	   ELSE tms.efforts END							
	FROM #timesheettickets(NOLOCK)  tst 
	JOIN @timesheeteffortmini tms ON tst.sessionid=tms.sessionid
	JOIN #groupedtickets(NOLOCK)  ms ON tst.sessionid=ms.sessionid											
				
		
	UPDATE td set td.tickettypemapid = ISNULL(ms.tickettypemapid,0),
	modifieddate=GETDATE(),lastupdateddate = GETDATE() 
	FROM avl.tk_trn_ticketdetail td 
	INNER JOIN #timesheettickets(NOLOCK)  tst on tst.ticketid=td.ticketid AND tst.projectid = td.projectid 
	INNER JOIN @timesheeteffortmini ms on tst.sessionid=ms.sessionid
	INNER JOIN avl.mas_projectmaster(NOLOCK)  pm on pm.projectid=td.projectid AND pm.isdeleted=0
	INNER JOIN avl.customer(NOLOCK)  c on c.customerid=pm.customerid AND c.isdeleted=0 AND c.iscognizant=0
	where ISNULL(tst.isnondelivery,0)=0 AND tst.[Type] ='T'

	--Infra
	UPDATE td set td.tickettypemapid = ISNULL(ms.tickettypemapid,0),
	modifieddate=GETDATE(),lastupdateddate = GETDATE() 
	FROM avl.TK_TRN_infraTicketDetail td 
	INNER JOIN #timesheettickets tst on tst.ticketid=td.ticketid AND tst.projectid = td.projectid 
	INNER JOIN @timesheeteffortmini ms on tst.sessionid=ms.sessionid
	INNER JOIN avl.mas_projectmaster pm on pm.projectid=td.projectid AND pm.isdeleted=0
	--INNER JOIN avl.customer c on c.customerid=pm.customerid AND c.isdeleted=0 AND c.iscognizant=0
	where tst.[Type] ='I'

	UPDATE WID set WID.WorkTypeMapId = ISNULL(ms.tickettypemapid,0),
	modifieddate=GETDATE()
	FROM ADM.ALM_TRN_WorkItem_Details(nolock) WID 
	INNER JOIN #timesheettickets(NOLOCK) tst on tst.ticketid=WID.WorkItem_Id AND tst.projectid = WID.Project_Id 
	INNER JOIN @timesheeteffortmini ms on tst.sessionid=ms.sessionid
	INNER JOIN avl.mas_projectmaster(NOLOCK) pm on pm.projectid=WID.Project_Id AND pm.isdeleted=0
	INNER JOIN avl.customer(NOLOCK) c on c.customerid=pm.customerid AND c.isdeleted=0 AND c.iscognizant=0
	where ISNULL(tst.isnondelivery,0)=0 AND tst.[Type] = 'W'

	CREATE TABLE #ProjectsSupportType
	(
	ProjectID BIGINT NOT NULL,
	IsDevProject INT NULL
	)
	INSERT INTO #ProjectsSupportType
	SELECT DISTINCT ProjectID,0 FROM #timesheettickets(NOLOCK) WHERE ProjectID IS NOT NULL

	UPDATE ST
	SET ST.IsDevProject =1  FROM
	#ProjectsSupportType(NOLOCK) ST
	INNER JOIN avl.map_ProjectConfig(NOLOCK) PC ON ST.projectid = PC.projectid 
	WHERE PC.SupportTypeId =4

	UPDATE ST
	SET ST.IsDevProject =1  FROM
	#ProjectsSupportType(NOLOCK) ST
	INNER JOIN pp.ProjectAttributeValues(NOLOCK) PAV on ST.projectid = PAV.ProjectID AND ISNULL(PAV.IsDeleted,0) = 0  AND PAV.AttributeID=1
	WHERE PAV.AttributeValueID IN(1,4) AND PAV.AttributeValueID NOT IN(2,3)
	
	UPDATE ST
	SET ST.IsDevProject =0  FROM
	#ProjectsSupportType(NOLOCK) ST
	INNER JOIN avl.map_ProjectConfig(NOLOCK) PC ON ST.projectid = PC.projectid 
	WHERE PC.SupportTypeId IN(1,3)

	---Infra
	UPDATE ST
	SET ST.IsDevProject =2  FROM
	#ProjectsSupportType ST
	INNER JOIN avl.map_ProjectConfig(NOLOCK) PC ON ST.projectid = PC.projectid 
	WHERE PC.SupportTypeId =2

	--UPDATE ST
	--SET ST.IsDevProject =2  FROM
	--#ProjectsSupportType ST
	--INNER JOIN pp.ProjectAttributeValues(NOLOCK) PAV on ST.projectid = PAV.ProjectID AND ISNULL(PAV.IsDeleted,0) = 0  AND PAV.AttributeID=1
	--WHERE PAV.AttributeValueID=3
	
	IF(@mode='Mini')
		BEGIN
			UPDATE td set td.serviceid = ISNULL(tst.serviceid,0),modifieddate=getdate(),lastupdateddate = getdate() 
			FROM avl.tk_trn_ticketdetail(NOLOCK) td 
			INNER JOIN #timesheettickets(NOLOCK) tst on tst.ticketid=td.ticketid AND tst.projectid = td.projectid
			inner join @timesheeteffortmini ms on tst.sessionid=ms.sessionid
			where ISNULL(tst.isnondelivery,0)=0 AND td.modifieddate < ISNULL(ms.modifiedon,ms.createdon)
						
			--SUM OF EFFORTS FOR EFFORT TILL DATE
			SELECT SUM(totaleffort) AS Efforts,ticketid,projectid
			INTO #Efforts FROM #timesheettickets(NOLOCK) 
			WHERE ISNULL(isnondelivery,0)=0
			GROUP BY ticketid,projectid

			SELECT SUM(totaleffort) AS Efforts,ticketid,projectid,userid,
			CONVERT(DATE,usercreatedtimedate) AS usercreatedtimedate,
			ISNULL(serviceid,0) AS serviceid,ISNULL(activityid,0) as activityid
			INTO #EffortsForTimeSheet FROM #timesheettickets(NOLOCK)  
			GROUP BY ticketid,projectid,userid,CONVERT(DATE,usercreatedtimedate) ,ISNULL(serviceid,0),
			ISNULL(activityid,0)

					
			UPDATE TT SET TT.totaleffort=ET.Efforts
			FROM #timesheettickets(NOLOCK) TT
			INNER JOIN #EffortsForTimeSheet(NOLOCK) ET ON  TT.ticketid=ET.ticketid AND TT.projectid = ET.projectid 
			AND TT.userid=ET.userid AND CONVERT(DATE,TT.usercreatedtimedate)=CONVERT(DATE,ET.usercreatedtimedate)
			AND ISNULL(TT.serviceid,0)=ISNULL(ET.serviceid,0) AND ISNULL(TT.activityid,0)=ISNULL(ET.activityid,0)
			where ISNULL(TT.isnondelivery,0)=0


			SELECT SUM(totaleffort) AS Efforts,TT.ticketid,TS.NonDeliveryActivityType,TT.projectid,TT.userid,
			CONVERT(DATE,TT.usercreatedtimedate) AS usercreatedtimedate
			INTO #EffortsNon
			FROM #timesheettickets(NOLOCK) TT
			INNER JOIN @tickersession TS ON TT.sessionid=TS.sessionid 
			where ISNULL(TT.isnondelivery,0)=1
			GROUP BY TT.ticketid,TS.NonDeliveryActivityType,TT.projectid,TT.userid,
			CONVERT(DATE,TT.usercreatedtimedate)

			UPDATE td set td.efforttilldate = td.efforttilldate + tst.Efforts,
			modifieddate=getdate(),lastupdateddate = getdate() FROM avl.tk_trn_ticketdetail(NOLOCK) td 
			join #Efforts(NOLOCK) tst on tst.ticketid=td.ticketid AND tst.projectid = td.projectid 
						
			DROP TABLE #Efforts
			DROP TABLE #EffortsForTimeSheet
		END
	ELSE
	BEGIN
		
	SELECT ticketid as ticketid ,MAX(usercreatedtimedate) as usercreatedtimedate 
	INTO #tsservice 
	FROM #timesheettickets(NOLOCK) GROUP BY ticketid


	UPDATE td set td.serviceid = ISNULL(tst.serviceid,0),modifieddate=getdate(),lastupdateddate = getdate() 
	FROM avl.tk_trn_ticketdetail(NOLOCK) td 
	INNER JOIN #timesheettickets(NOLOCK) tst on tst.projectid = td.projectid  AND tst.ticketid=td.ticketid 
	INNER JOIN @timesheeteffortmini ms on tst.sessionid=ms.sessionid
	INNER JOIN  #tsservice(NOLOCK) tss on tss.ticketid=td.ticketid AND tss.usercreatedtimedate=tst.usercreatedtimedate
	where ISNULL(tst.isnondelivery,0)=0 AND tst.[Type] ='T'

	--Infra
	UPDATE td set td.serviceid = ISNULL(tst.serviceid,0),modifieddate=getdate(),lastupdateddate = getdate() 
	FROM avl.TK_TRN_infraTicketDetail td 
	INNER JOIN #timesheettickets tst on tst.projectid = td.projectid  AND tst.ticketid=td.ticketid 
	INNER JOIN @timesheeteffortmini ms on tst.sessionid=ms.sessionid
	--INNER JOIN  #tsservice tss on tss.ticketid=td.ticketid AND tss.usercreatedtimedate=tst.usercreatedtimedate  
	where tst.[Type] ='I'

	UPDATE WID set WID.serviceid = ISNULL(tst.serviceid,0),modifieddate=getdate() 
	FROM ADM.ALM_TRN_WorkItem_Details(nolock) WID 
	INNER JOIN #timesheettickets(NOLOCK) tst on tst.projectid = WID.Project_Id AND tst.ticketid=WID.WorkItem_Id  
	INNER JOIN @timesheeteffortmini ms on tst.sessionid=ms.sessionid
	INNER JOIN  #tsservice(NOLOCK) tss on tss.ticketid=WID.WorkItem_Id AND tss.usercreatedtimedate=tst.usercreatedtimedate
	where ISNULL(tst.isnondelivery,0)=0 AND tst.[Type] = 'W'
	
	END

	UPDATE tst set tst.customerid =pm.customerid,tst.iscognizant=c.iscognizant FROM #timesheettickets tst 
	INNER JOIN avl.mas_projectmaster(NOLOCK) pm on tst.projectid=pm.projectid
	INNER JOIN avl.customer(NOLOCK) c on pm.customerid=c.customerid

	UPDATE tst  set tst.nonticketdescription=ms.nonticketdescription,
	tst.activityid=ms.nondeliveryactivitytype
	FROM #timesheettickets(NOLOCK) tst 
	JOIN @timesheeteffortmini ms on tst.sessionid=ms.sessionid 
	WHERE tst.isnondelivery=1


	CREATE TABLE #newtimesheetentry
	(
	CustomerID BIGINT NULL,
	ProjectID BIGINT NULL,
	UserID Bigint NULL,
	TimeSheetDate date NULL,
	StatusID INT NULL,
	EmployeeID NVARCHAR(100) NULL 
	)	
				
	INSERT INTO #newtimesheetentry
	SELECT customerid as customerid,projectid as projectid,userid as userid,
	convert(date,usercreatedtimedate) as timesheetdate,1 AS StatusID,'' AS EmployeeID FROM #timesheettickets
	except
	SELECT DISTINCT PT.customerid as customerid,PT.projectid as projectid,PT.submitterid as submitterid,
	convert(date,PT.timesheetdate) as timesheetdate,1 AS StatusID,'' AS EmployeeID  
	FROM AVL.TM_PRJ_Timesheet(NOLOCK) PT
	INNER JOIN #timesheettickets(NOLOCK) TT ON TT.customerid=TT.customerid 
	AND convert(date,TT.usercreatedtimedate) =convert(date,timesheetdate)  
	AND TT.projectid=PT.ProjectID AND TT.userid=PT.SubmitterId



	SELECT a.* into  #updatetimesheetentry  from
	(
	SELECT customerid as customerid,projectid as projectid,userid as userid,
	convert(date,usercreatedtimedate) as timesheetdate FROM #timesheettickets(NOLOCK)
	intersect
	SELECT DISTINCT PT.customerid as customerid,PT.projectid as projectid,PT.submitterid as submitterid,
	convert(date,PT.timesheetdate) as timesheetdate FROM AVL.TM_PRJ_Timesheet(NOLOCK) PT
	INNER JOIN #timesheettickets(NOLOCK) TT ON TT.customerid=TT.customerid 
	AND convert(date,TT.usercreatedtimedate) =convert(date,timesheetdate)
	AND TT.projectid=PT.ProjectID AND TT.userid=PT.SubmitterId
	)as a

	UPDATE NT SET NT.EmployeeID=LM.EmployeeID FROM
	 #newtimesheetentry(NOLOCK) NT
	INNER JOIN AVL.MAS_LoginMaster(NOLOCK) LM ON NT.ProjectID = LM.ProjectID
	AND NT.UserID=LM.UserID

	CREATE TABLE #TM_PRJ_TimesheetTemp
	(
	CustomerID BIGINT NULL,
	TimeSheetDate DATE NULL,
	ProjectID BIGINT NULL,
	SubmitterID BIGINT NULL,
	EmployeeID NVARCHAR(100) NULL,
	StatusID INT NULL
	)
	
	 SELECT DISTINCT NT.EmployeeID, LM.UserID INTO #UserTemp FROM  #newtimesheetentry (NOLOCK) NT
	 INNER JOIN AVL.MAS_LoginMaster(NOLOCK) LM ON NT.CustomerID = LM.CustomerID AND NT.EmployeeID=LM.EmployeeID

	INSERT 	INTO #TM_PRJ_TimesheetTemp
	SELECT DISTINCT PT.CustomerID,PT.TimeSheetDate,PT.ProjectID,PT.SubmitterID,NULL,PT.StatusID
	FROM #newtimesheetentry (NOLOCK) NT 
	INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) PT ON NT.CustomerID=PT.CustomerID
	AND NT.TimesheetDate=PT.TimeSheetDate
	INNER JOIN #UserTemp(NOLOCK) UT ON UT.UserID=PT.SubmitterID


	UPDATE NT SET NT.EmployeeID=LM.EmployeeID FROM
	 #TM_PRJ_TimesheetTemp(NOLOCK) NT
	INNER JOIN AVL.MAS_LoginMaster(NOLOCK) LM ON NT.CustomerID = LM.CustomerID
	AND NT.SubmitterID=LM.UserID

	UPDATE NT SET NT.StatusID=ISNULL(PT.StatusID,1) FROM #newtimesheetentry(NOLOCK) NT
	INNER JOIN  #TM_PRJ_TimesheetTemp(NOLOCK) PT
	ON NT.CustomerID=PT.CustomerID AND NT.timesheetdate=PT.TimesheetDate
	AND NT.EmployeeID=PT.EmployeeID
	--Code Block that updates the Status ID

	insert into avl.tm_prj_timesheet(customerid,projectid,submitterid, timesheetdate,statusid,
	createdby,createddatetime)
	SELECT distinct customerid,projectid,userid,cast(timesheetdate as date),StatusID, @mode, getdate() 
	FROM #newtimesheetentry(NOLOCK)	--#timesheettickets

	UPDATE td set td.modifiedby=@mode,modifieddatetime=getdate() 
	FROM  avl.tm_prj_timesheet(NOLOCK) td
	inner join #updatetimesheetentry(NOLOCK) te on td.customerid=te.customerid AND td.projectid=te.projectid
	AND td.submitterid=te.userid AND td.timesheetdate=te.timesheetdate

	UPDATE tst set tst.timesheetid=ts.timesheetid FROM avl.tm_prj_timesheet(NOLOCK) ts 
	inner join #timesheettickets(NOLOCK) tst on ts.projectid=tst.projectid AND ts.submitterid=tst.userid 
	AND ts.timesheetdate=cast(tst.usercreatedtimedate as date)
				
	UPDATE #timesheettickets set ticketid='NonDelivery' where isnondelivery=1
	if(@mode='Mini')
	begin
				
	UPDATE TT SET TT.totalEffort=EN.Efforts FROM #timesheettickets(NOLOCK) TT
	INNER JOIN  #EffortsNon(NOLOCK) EN ON TT.projectid=EN.projectID AND TT.activityid=EN.NonDeliveryActivityType
	AND TT.userid=EN.userid AND CONVERT(DATE,TT.usercreatedtimedate)=CONVERT(DATE,EN.usercreatedtimedate)
	AND TT.isnondelivery=1

	END
	
	--code block tickets to get inserted to timesheet details cognizant	

	SELECT b.* into #timesheetinserttickets from
	(SELECT timesheetid,timetickerid,isnondelivery,serviceid,ISNULL(activityid,0) AS activityid,projectid,
	0 as isdeleted
	FROM #timesheettickets(NOLOCK) where iscognizant=1 AND [Type] ='T'
	EXCEPT
	SELECT TDS.timesheetid,TDS.timetickerid,TDS.isnonticket,TDS.serviceid,ISNULL(TDS.activityid,0) AS activityid,TDS.projectid,TDS.isdeleted 
	FROM #timesheettickets(NOLOCK) TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) td ON TT.customerid=td.CustomerId AND TT.usercreatedtimedate=Td.TimesheetDate
	AND TT.userid=td.submitterId
	INNER JOIN avl.tm_trn_timesheetdetail(NOLOCK) TDS ON td.TimesheetId=TDS.TimesheetId 
	WHERE ISNULL(TDS.isdeleted,0)=0 AND TDS.isnonticket=0
	)as b

	--Infra
	INSERT INTO #timesheetinserttickets
	(timesheetid,timetickerid,isnondelivery,projectid,isdeleted,activityid)
	SELECT b.* from(SELECT timesheetid,timetickerid,isnondelivery,projectid,0 as isdeleted,ISNULL(activityid,0) AS activityid
	FROM #timesheettickets TR where iscognizant=1 AND [Type] ='I'
	EXCEPT
	SELECT TDS.timesheetid,TDS.timetickerid,TDS.isnonticket,TDS.projectid,TDS.isdeleted,ISNULL(TDS.TaskId,0) AS activityid
	FROM #timesheettickets TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) td ON TT.customerid=td.CustomerId AND TT.usercreatedtimedate=Td.TimesheetDate
	AND TT.userid=td.submitterId
	INNER JOIN avl.TM_TRN_InfraTimesheetDetail(NOLOCK) TDS ON td.TimesheetId=TDS.TimesheetId 
	WHERE ISNULL(TDS.isdeleted,0)=0 AND TDS.isnonticket=0
	)as b
	

	INSERT INTO #timesheetinserttickets
	(timesheetid,timetickerid,isnondelivery,serviceid,activityid,isdeleted)
	SELECT b.* from(SELECT timesheetid,timetickerid,isnondelivery,serviceid,ISNULL(activityid,0) 
	AS activityid,0 as isdeleted
	FROM #timesheettickets(NOLOCK) where iscognizant=1 AND [Type] ='W'
	EXCEPT
	SELECT TDS.timesheetid,TDS.WorkItemDetailsId,TDS.isnonticket,TDS.serviceid,ISNULL(TDS.activityid,0) AS activityid,TDS.isdeleted 
	FROM #timesheettickets(NOLOCK) TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) td ON TT.customerid=td.CustomerId AND TT.usercreatedtimedate=Td.TimesheetDate
	AND TT.userid=td.submitterId
	INNER JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) TDS ON td.TimesheetId=TDS.TimesheetId 
	WHERE ISNULL(TDS.isdeleted,0)=0 AND TDS.isnonticket=0

	
	)as b

	SELECT b.* into #timesheetupdatetickets FROM
	(SELECT timesheetid,timetickerid,isnondelivery,serviceid,ISNULL(activityid,0) AS activityid,projectid,
	0 AS isdeleted
	FROM #timesheettickets(NOLOCK) where iscognizant=1 AND [Type] ='T'
	INTERSECT
	SELECT TDS.timesheetid,TDS.timetickerid,TDS.isnonticket,TDS.serviceid,ISNULL(TDS.activityid,0) AS activityid,TDS.projectid,TDS.isdeleted 
	FROM #timesheettickets(NOLOCK) TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) td ON TT.customerid=td.CustomerId AND TT.usercreatedtimedate=Td.TimesheetDate
	AND TT.userid=td.submitterId
	INNER JOIN avl.tm_trn_timesheetdetail(NOLOCK) TDS ON td.TimesheetId=TDS.TimesheetId 
	WHERE ISNULL(TDS.isdeleted,0)=0 AND TDS.isnonticket=0
	
	)as b

	---Infra
	INSERT INTO #timesheetupdatetickets
	(timesheetid,timetickerid,isnondelivery,projectid,isdeleted,activityid)
	SELECT b.* from(SELECT timesheetid,timetickerid,isnondelivery,projectid,0 as isdeleted, ISNULL(activityid,0) AS activityid
	FROM #timesheettickets TR where iscognizant=1 AND [Type] ='I'
	EXCEPT
	SELECT TDS.timesheetid,TDS.timetickerid,TDS.isnonticket,TDS.projectid,TDS.isdeleted,ISNULL(TDS.TaskId,0) AS activityid
	FROM #timesheettickets TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) td ON TT.customerid=td.CustomerId AND TT.usercreatedtimedate=Td.TimesheetDate
	AND TT.userid=td.submitterId
	INNER JOIN avl.TM_TRN_InfraTimesheetDetail(NOLOCK) TDS ON td.TimesheetId=TDS.TimesheetId 
	WHERE ISNULL(TDS.isdeleted,0)=0 
	)as b
	
	INSERT INTO #timesheetupdatetickets
	(timesheetid,timetickerid,isnondelivery,serviceid,activityid,isdeleted)
	SELECT b.* FROM	(SELECT timesheetid,timetickerid,isnondelivery,serviceid,ISNULL(activityid,0) AS activityid,
	0 AS isdeleted
	FROM #timesheettickets(NOLOCK) where iscognizant=1 AND [Type] ='W'
	INTERSECT
	SELECT TDS.timesheetid,TDS.WorkItemDetailsId,TDS.isnonticket,TDS.serviceid,ISNULL(TDS.activityid,0) AS activityid,TDS.isdeleted 
	FROM #timesheettickets(NOLOCK) TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) td ON TT.customerid=td.CustomerId AND TT.usercreatedtimedate=Td.TimesheetDate
	AND TT.userid=td.submitterId
	INNER JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) TDS ON td.TimesheetId=TDS.TimesheetId 
	WHERE ISNULL(TDS.isdeleted,0)=0 AND TDS.isnonticket=0
	
	)as b		


	INSERT INTO avl.tm_trn_timesheetdetail
	(timesheetid,timetickerid,applicationid,ticketid,isnonticket,serviceid,activityid,tickettypemapid,
	hours,projectid,isdeleted,createdby,createddatetime,remarks)
	SELECT DISTINCT tii.timesheetid,tii.timetickerid,ts.applicationid,ts.ticketid,tii.isnondelivery,tii.serviceid,
	tii.activityid,TD.tickettypemapid,
	ts.totaleffort,tii.projectid,0,@mode,getdate(),null
	FROM #timesheetinserttickets(NOLOCK) tii
	inner join #timesheettickets(NOLOCK) ts on tii.timesheetid=ts.timesheetid AND tii.projectid=ts.projectid
	AND tii.isnondelivery=0 AND  iscognizant=1 AND tii.timetickerid=ts.timetickerid
	AND ISNULL(tii.serviceid,0)=ISNULL(ts.serviceid,0)  AND ISNULL(tii.activityid,0)=ISNULL(ts.activityid,0)
	INNER JOIN AVL.TK_TRN_TicketDetail(NOLOCK) TD on tii.timetickerid= TD.TimeTickerID   AND tii.projectid=TD.ProjectID
	where ts.[Type] ='T'

	--Infra
	--UPDATE td SET
	--td.hours= CASE WHEN @mode='Mini' then td.hours + ts.totaleffort
	--ELSE ts.totaleffort END ,
	--modifiedby=ts.employeeid,modifieddatetime=getdate()
	--FROM avl.TM_TRN_InfraTimesheetDetail td
	--inner join  #timesheetupdatetickets tii on td.timesheetid=tii.timesheetid AND td.timetickerid=tii.timetickerid
	--inner join #timesheettickets ts on tii.timesheetid=ts.timesheetid AND tii.projectid=ts.projectid
	----AND ISNULL(td.serviceid,0)=ISNULL(tii.serviceid,0) AND ISNULL(td.activityid,0)=ISNULL(tii.activityid,0) 
	--AND td.isnonticket=0 AND  iscognizant=1 AND tii.timetickerid=ts.timetickerid
	--where ts.[Type] ='I'

	UPDATE td SET
	td.hours= CASE WHEN @mode='Mini' then td.hours + ts.totaleffort
	ELSE ts.totaleffort END ,
	modifiedby=ts.employeeid,modifieddatetime=getdate()
	FROM avl.TM_TRN_InfraTimesheetDetail td
	--inner join  #timesheettickets tii on td.timesheetid=tii.timesheetid --AND td.timetickerid=tii.timetickerid
	inner join #timesheettickets ts on  td.projectid=ts.projectid AND td.timesheetid=ts.timesheetid AND td.TaskId=ts.activityid
	--AND ISNULL(td.serviceid,0)=ISNULL(tii.serviceid,0) AND ISNULL(td.activityid,0)=ISNULL(tii.activityid,0) 
	AND  iscognizant=1  AND td.timetickerid=ts.timetickerid
	where ts.[Type] ='I'

    INSERT INTO avl.TM_TRN_InfraTimesheetDetail
	(TimesheetId,TimeTickerID,TowerID,TicketID,IsNonTicket,TaskId,TicketTypeMapID,	
	Hours,Remarks,ProjectId,IsDeleted,CreatedBy,CreatedDateTime)
	SELECT DISTINCT ts.timesheetid,tii.timetickerid,ts.TowerID,ts.ticketid,Isnull(tii.isnondelivery,0),tii.ActivityID,TD.tickettypemapid,ts.totaleffort
	,tm.nonticketdescription,tii.projectid,0,tm.employeeid,getdate()
	FROM #timesheetinserttickets tii
	inner join #timesheettickets ts on tii.timesheetid=ts.timesheetid AND tii.projectid=ts.projectid
	left join @timesheeteffortmini tm on  tii.timetickerid=tm.timetickerid AND tii.projectid=tm.projectid and ts.employeeid=tm.employeeid
	AND isnull(tii.isnondelivery,0)=0 AND  iscognizant=1 AND tii.timetickerid=ts.timetickerid
	AND ISNULL(tii.activityid,0)=ISNULL(ts.activityid,0)
	INNER JOIN AVL.TK_TRN_infraTicketDetail(NOLOCK) TD on tii.timetickerid= TD.TimeTickerID   AND tii.projectid=TD.ProjectID
	where ts.[Type] ='I' and tm.employeeid is not null

	INSERT INTO ADM.TM_TRN_WorkItemTimesheetDetail 
	(timesheetid,WorkItemDetailsId,serviceid,activityid,hours,isnonticket,remarks,isdeleted,createdby,CreatedDate)
	SELECT DISTINCT tii.timesheetid,tii.timetickerid,tii.serviceid,
	tii.activityid,	ts.totaleffort,tii.isnondelivery,null,0,@mode,getdate()
	FROM #timesheetinserttickets tii
	inner join #timesheettickets ts on tii.timesheetid=ts.timesheetid
	AND tii.isnondelivery=0 AND  iscognizant=1 AND tii.timetickerid=ts.timetickerid
	AND ISNULL(tii.serviceid,0)=ISNULL(ts.serviceid,0)  AND ISNULL(tii.activityid,0)=ISNULL(ts.activityid,0)
	INNER JOIN ADM.ALM_TRN_WorkItem_Details(NOLOCK) WID on WID.WorkItemDetailsId = tii.timetickerid
	where ts.[Type] ='W'

	UPDATE td SET
	td.hours= CASE WHEN @mode='Mini' then td.hours + ts.totaleffort
	ELSE ts.totaleffort END ,
	modifiedby=@mode,modifieddatetime=getdate()
	FROM avl.tm_trn_timesheetdetail(NOLOCK) td
	inner join  #timesheetupdatetickets(NOLOCK) tii on td.timesheetid=tii.timesheetid AND td.timetickerid=tii.timetickerid
	inner join #timesheettickets(NOLOCK) ts on tii.timesheetid=ts.timesheetid AND tii.projectid=ts.projectid
	AND ISNULL(td.serviceid,0)=ISNULL(tii.serviceid,0) AND ISNULL(td.activityid,0)=ISNULL(tii.activityid,0) 
	AND td.isnonticket=0 AND  iscognizant=1 AND tii.timetickerid=ts.timetickerid
	where ts.[Type] ='T'



	UPDATE WITM SET
	WITM.hours= CASE WHEN @mode='Mini' then WITM.hours + ts.totaleffort
	ELSE ts.totaleffort END,
	modifiedby=@mode,ModifiedDate=getdate()
	FROM ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) WITM
	inner join  #timesheetupdatetickets(NOLOCK) tii on WITM.timesheetid=tii.timesheetid AND WITM.WorkItemDetailsId=tii.timetickerid
	inner join #timesheettickets(NOLOCK) ts on tii.timesheetid=ts.timesheetid 
	AND ISNULL(WITM.serviceid,0)=ISNULL(tii.serviceid,0) AND ISNULL(WITM.activityid,0)=ISNULL(tii.activityid,0) 
	AND WITM.isnonticket= 0 AND  iscognizant=1 AND tii.timetickerid=ts.timetickerid
	where ts.[Type] ='W'
	--code block end for timesheet details
			
	--code block tickets to get inserted to timesheet details customer
	SELECT b.* into #timesheetdetailscustomerinsert from
	(SELECT timesheetid,timetickerid,isnondelivery,tickettypemapid,projectid,0 as isdeleted
	FROM #timesheettickets(NOLOCK) where iscognizant=0
	EXCEPT
	SELECT TDS.timesheetid,TDS.timetickerid,TDS.isnonticket,TDS.tickettypemapid,TDS.projectid,TDS.isdeleted 
	FROM #timesheettickets(NOLOCK) TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) td ON TT.customerid=td.CustomerId AND TT.usercreatedtimedate=Td.TimesheetDate
	AND TT.userid=td.submitterId
	INNER JOIN avl.tm_trn_timesheetdetail(NOLOCK) TDS ON td.TimesheetId=TDS.TimesheetId 
	WHERE ISNULL(TDS.isdeleted,0)=0 AND TDS.isnonticket=0
	
	)as b

	SELECT b.* into #timesheetdetailscustomerupdate FROM
	(SELECT timesheetid,timetickerid,isnondelivery,tickettypemapid,projectid,0 as isdeleted
	FROM #timesheettickets(NOLOCK) WHERE iscognizant=0
	INTERSECT
	SELECT TDS.timesheetid,TDS.timetickerid,TDS.isnonticket,TDS.tickettypemapid,TDS.projectid,TDS.isdeleted 
	FROM #timesheettickets(NOLOCK) TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) td ON TT.customerid=td.CustomerId AND TT.usercreatedtimedate=Td.TimesheetDate
	AND TT.userid=td.submitterId
	INNER JOIN avl.tm_trn_timesheetdetail(NOLOCK) TDS ON td.TimesheetId=TDS.TimesheetId 
	WHERE ISNULL(TDS.isdeleted,0)=0 AND TDS.isnonticket=0
	)as b

	INSERT INTO avl.tm_trn_timesheetdetail
	(timesheetid,timetickerid, applicationid,ticketid,isnonticket,tickettypemapid,hours,projectid,
	isdeleted,createdby,createddatetime,remarks,serviceid,activityid)
	SELECT DISTINCT tii.timesheetid,tii.timetickerid,ts.applicationid,ts.ticketid,tii.isnondelivery,
	TD.tickettypemapid,ts.totaleffort,tii.projectid,0,@mode,GETDATE(),NULL,0,0 
	FROM #timesheetdetailscustomerinsert(NOLOCK) tii
	inner join #timesheettickets(NOLOCK) ts on tii.timesheetid=ts.timesheetid AND tii.projectid=ts.projectid
	AND tii.isnondelivery=0 and  iscognizant=0 AND tii.timetickerid=ts.timetickerid
	INNER JOIN AVL.TK_TRN_TicketDetail(nolock) TD on tii.timetickerid= TD.TimeTickerID AND tii.projectid=TD.ProjectID 
		
	UPDATE td SET 
	td.hours= CASE WHEN @mode='Mini' then td.hours + ts.totaleffort
	else ts.totaleffort end ,
	modifiedby=@mode,modifieddatetime=getdate()
	FROM avl.tm_trn_timesheetdetail(NOLOCK) td
	inner join  #timesheetdetailscustomerupdate(NOLOCK) tii on td.timesheetid=tii.timesheetid AND td.timetickerid=tii.timetickerid
	inner join #timesheettickets(NOLOCK) ts on tii.timesheetid=ts.timesheetid AND tii.projectid=ts.projectid
	AND ISNULL(td.tickettypemapid,0)=ISNULL(tii.tickettypemapid,0) 
	AND td.isnonticket=0 AND  iscognizant=0 AND tii.timetickerid=ts.timetickerid
				
	--code block end for timesheet details
	--for non delivery tickets


	SELECT b.* into #timesheetnondeliveryinserttickets from
	(SELECT timesheetid,isnondelivery,activityid,projectid,0 as isdeleted
	FROM #timesheettickets(NOLOCK) where isnondelivery=1
	except
		SELECT TDS.timesheetid,TDS.isnonticket,TDS.activityid,TDS.projectid,0 AS isdeleted 
		FROM #timesheettickets(NOLOCK) TT
		INNER JOIN avl.tm_prj_timesheet(NOLOCK) td ON TT.customerid=td.CustomerId AND TT.usercreatedtimedate=Td.TimesheetDate
		AND TT.userid=td.submitterId
		INNER JOIN avl.tm_trn_timesheetdetail(NOLOCK) TDS ON td.TimesheetId=TDS.TimesheetId 
		WHERE ISNULL(TDS.isdeleted,0)=0 AND TDS.isnonticket=1
  
  
  )as b
	
	SELECT b.*   into #timesheetnondeliveryinsertworkitems from
	(SELECT timesheetid,isnondelivery,activityid,0 as isdeleted
	FROM #timesheettickets(NOLOCK) where isnondelivery=1 
	except
	SELECT TDS.timesheetid,TDS.isnonticket,TDS.activityid,0 as isdeleted
	FROM #timesheettickets(NOLOCK) TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) td ON TT.customerid=td.CustomerId AND TT.usercreatedtimedate=Td.TimesheetDate
	INNER JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) TDS ON td.TimesheetId=TDS.TimesheetId 
	WHERE ISNULL(TDS.isdeleted,0)=0 AND TDS.isnonticket=1
	
	)as b

	----Infra
	SELECT b.* into #timesheetnondeliveryinsertInfratickets from
	(SELECT timesheetid,isnondelivery,activityid,projectid,0 as isdeleted
	FROM #timesheettickets where isnondelivery=1
	except
	SELECT TDS.timesheetid,TDS.isnonticket,TDS.TaskId,TDS.projectid,0 AS isdeleted 
	FROM #timesheettickets TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) td ON TT.customerid=td.CustomerId AND TT.usercreatedtimedate=Td.TimesheetDate
	AND TT.userid=td.submitterId
	INNER JOIN avl.TM_TRN_InfraTimesheetDetail(NOLOCK) TDS ON td.TimesheetId=TDS.TimesheetId 
	WHERE ISNULL(TDS.isdeleted,0)=0 AND TDS.isnonticket=1   
	)as b

	SELECT b.* into #timesheetnondeliveryupdatetickets from
	(SELECT timesheetid,isnondelivery,activityid,projectid,0 as isdeleted
	FROM #timesheettickets(NOLOCK) where isnondelivery=1
	intersect
	SELECT TDS.timesheetid,TDS.isnonticket,TDS.activityid,TDS.projectid,0 AS isdeleted 
	FROM #timesheettickets(NOLOCK) TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) td ON TT.customerid=td.CustomerId AND TT.usercreatedtimedate=Td.TimesheetDate
	AND TT.userid=td.submitterId
	INNER JOIN avl.tm_trn_timesheetdetail(NOLOCK) TDS ON td.TimesheetId=TDS.TimesheetId 
	WHERE ISNULL(TDS.isdeleted,0)=0 AND TDS.isnonticket=1
	
	)as b

	
	SELECT b.* into #timesheetnondeliveryupdateworkitems from
	(SELECT timesheetid,isnondelivery,activityid,0 as isdeleted
	FROM #timesheettickets(NOLOCK) where isnondelivery=1 
	intersect
	SELECT TDS.timesheetid,TDS.isnonticket,TDS.activityid,0 as isdeleted
	FROM #timesheettickets(NOLOCK) TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) td ON TT.customerid=td.CustomerId AND TT.usercreatedtimedate=Td.TimesheetDate
	--AND TT.userid=td.submitterId
	INNER JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) TDS ON td.TimesheetId=TDS.TimesheetId 
	WHERE ISNULL(TDS.isdeleted,0)=0 AND TDS.isnonticket=1
	
	
	)as b
    ---- Infra
	SELECT b.* into #timesheetnondeliveryupdateInfra FROM
	(SELECT timesheetid,timetickerid,isnondelivery,serviceid,ISNULL(activityid,0) AS activityid,projectid,
	0 AS isdeleted
	FROM #timesheettickets where isnondelivery=1 
	INTERSECT
	SELECT TDS.timesheetid,TDS.timetickerid,TDS.isnonticket,TDS.TicketTypeMapID,ISNULL(TDS.TaskId,0) AS activityid,TDS.projectid,TDS.isdeleted 
	FROM #timesheettickets TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) td ON TT.customerid=td.CustomerId AND TT.usercreatedtimedate=Td.TimesheetDate
	AND TT.userid=td.submitterId
	INNER JOIN avl.TM_TRN_InfraTimesheetDetail(NOLOCK) TDS ON td.TimesheetId=TDS.TimesheetId 
	WHERE ISNULL(TDS.isdeleted,0)=0 AND TDS.isnonticket=1
	
	)as b

 	INSERT INTO avl.tm_trn_timesheetdetail(timesheetid,timetickerid, applicationid,ticketid,isnonticket,
	serviceid,activityid,tickettypemapid,hours,projectid,isdeleted,createdby,createddatetime,remarks)
  	SELECT DISTINCT tii.timesheetid,0,0,ts.ticketid,tii.isnondelivery,0,tii.activityid,0,
	ts.totaleffort,tii.projectid,0,@mode,GETDATE(),ts.nonticketdescription 
	FROM #timesheetnondeliveryinserttickets(NOLOCK) tii
	inner join #timesheettickets(NOLOCK) ts on tii.timesheetid=ts.timesheetid AND tii.projectid=ts.projectid
  AND tii.isnondelivery=1  AND tii.activityid=ts.activityid
	where  ts.iscognizant = 0
	
	SELECT DISTINCT TimeTickerID,projectid,[Type]
	INTO #Efforttilldate
	FROM #timesheettickets(NOLOCK) TT
	
	SELECT SUM(TD.Hours) as efforttilldate, TD.TimeTickerID, TS.ProjectID, tt.[Type]
	INTO #tmpefforts_T FROM #Efforttilldate TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) TS ON TT.projectid=TS.ProjectID 
	INNER JOIN AVL.TM_TRN_TimesheetDetail(NOLOCK) TD ON TS.TimesheetId = td.timesheetid AND  TT.timetickerid=TD.TimeTickerID 
	AND ISNULL(TD.IsDeleted,0)=0
	WHERE TT.[Type] ='T'
	GROUP BY TD.TimeTickerID, TS.ProjectID, tt.[Type]

	--Infra
	SELECT SUM(TD.Hours) as efforttilldate, TD.TimeTickerID, TS.ProjectID, tt.[Type]
	INTO #tmpefforts_I FROM #Efforttilldate TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) TS ON TT.projectid=TS.ProjectID 
	INNER JOIN AVL.TM_TRN_InfraTimesheetDetail(NOLOCK) TD ON TS.TimesheetId = td.timesheetid AND  TT.timetickerid=TD.TimeTickerID 
	AND ISNULL(TD.IsDeleted,0)=0
	WHERE TT.[Type] ='I'
	GROUP BY TD.TimeTickerID, TS.ProjectID, tt.[Type]

	SELECT SUM(TD.Hours) as efforttilldate, TD.WorkItemDetailsId, TS.ProjectID, TT.[Type]
	INTO #tmpefforts_w FROM #Efforttilldate TT
	INNER JOIN avl.tm_prj_timesheet(NOLOCK) TS ON TT.projectid=TS.ProjectID 
	INNER JOIN ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) TD ON TS.TimesheetId = td.timesheetid AND TT.timetickerid=TD.WorkItemDetailsId 
	AND ISNULL(TD.IsDeleted,0)=0
	WHERE TT.[Type] ='W'
	GROUP BY TD.WorkItemDetailsId, TS.ProjectID, TT.[Type]

	
	UPDATE td set td.efforttilldate=te.efforttilldate FROM avl.tk_trn_ticketdetail td join #tmpefforts_T(NOLOCK) te
	on te.projectid=td.projectid AND td.TimeTickerID=te.TimeTickerID
	where te.[Type] ='T'

	--Infra
	UPDATE td set td.efforttilldate=te.efforttilldate FROM avl.TK_TRN_infraTicketDetail td join #tmpefforts_I te
	on te.projectid=td.projectid AND td.TimeTickerID=te.TimeTickerID
	where te.[Type] ='I'

	UPDATE WID set WID.WorkProfilerEffort=te.efforttilldate 
	FROM ADM.ALM_TRN_WorkItem_Details(nolock) WID join #tmpefforts_w te
	on te.projectid=WID.Project_Id AND WID.WorkItemDetailsId=te.WorkItemDetailsId
	where te.[Type] ='W'


	INSERT INTO avl.tm_trn_timesheetdetail(timesheetid,timetickerid, applicationid,ticketid,isnonticket,
	serviceid,activityid,tickettypemapid,hours,projectid,isdeleted,createdby,createddatetime,remarks)
	SELECT DISTINCT tii.timesheetid,0,0,ts.ticketid,tii.isnondelivery,0,tii.activityid,0,
	ts.totaleffort,tii.projectid,0,@mode,GETDATE(),ts.nonticketdescription 
	FROM #timesheetnondeliveryinserttickets(NOLOCK) tii
	inner join #timesheettickets(NOLOCK) ts on tii.timesheetid=ts.timesheetid AND tii.projectid=ts.projectid
  AND tii.isnondelivery=1  AND tii.activityid=ts.activityid
  LEFT JOIN #ProjectsSupportType(NOLOCK) PST ON ts.ProjectID=PST.projectid
	where ts.[Type] = 'ND' 
	AND  ts.iscognizant= 1 and ISNULL(PST.IsDevProject,0) =0


	insert into adm.tm_trn_workitemtimesheetdetail (timesheetid,workitemdetailsid,isnonticket,
	serviceid,activityid,hours,isdeleted,createdby,createddate,remarks)
	select distinct tii.timesheetid,null,tii.isnondelivery,null,tii.activityid,
	ts.totaleffort,0,@mode,getdate(),ts.nonticketdescription 
	from #timesheetnondeliveryinsertworkitems(NOLOCK) tii
	inner join #timesheettickets(NOLOCK) ts on tii.timesheetid=ts.timesheetid
  and tii.isnondelivery=1  and tii.activityid=ts.activityid
	 LEFT JOIN #ProjectsSupportType(NOLOCK) PST ON ts.ProjectID=PST.projectid
	where ts.[Type] = 'ND' AND ts.iscognizant = 1 AND  ISNULL(PST.IsDevProject,0) =1
	
	---infra
	--INSERT INTO avl.TM_TRN_InfraTimesheetDetail
	--(TimesheetId,TimeTickerID,TowerID,TicketID,IsNonTicket,TaskId,TicketTypeMapID,
	--Hours,Remarks,ProjectId,IsDeleted,CreatedBy,CreatedDateTime,SuggestedActivityID)
	--SELECT DISTINCT ts.timesheetid,tii.timetickerid,ts.TowerID,ts.ticketid,Isnull(tii.isnondelivery,0),tii.ActivityID,tm.TicketTypeMapID,ts.totaleffort
	--,tm.nonticketdescription,tii.projectid,0,tm.employeeid,getdate(),tm.SuggestedActivity
	--FROM #timesheetnondeliveryinsertInfratickets tii
	--inner join #timesheettickets ts on tii.timesheetid=ts.timesheetid AND tii.projectid=ts.projectid
-- AND tii.isnondelivery=1  AND tii.activityid=ts.activityid
 -- left join @timesheeteffortmini tm on  tii.timetickerid=tm.timetickerid AND tii.projectid=tm.projectid
 -- --INNER JOIN AVL.TK_TRN_infraTicketDetail(NOLOCK) TD on tii.timetickerid= TD.TimeTickerID   AND tii.projectid=TD.ProjectID
 -- LEFT JOIN #ProjectsSupportType PST ON ts.ProjectID=PST.projectid
	--where ts.[Type] = 'ND' 
	--AND  ts.iscognizant= 1 and ISNULL(PST.IsDevProject,0) =2

	UPDATE td SET
	td.hours= CASE WHEN @mode='Mini' then td.hours + ts.totaleffort
	ELSE ts.totaleffort END ,
	modifiedby=ts.employeeid,remarks=ts.nonticketdescription,modifieddatetime=getdate()
	FROM avl.TM_TRN_InfraTimesheetDetail td
	--inner join  #timesheettickets tii on td.timesheetid=tii.timesheetid --AND td.timetickerid=tii.timetickerid
	inner join #timesheettickets ts on  td.projectid=ts.projectid  AND td.TaskId=ts.activityid --AND td.timesheetid=ts.timesheetid
	--AND ISNULL(td.serviceid,0)=ISNULL(tii.serviceid,0) AND ISNULL(td.activityid,0)=ISNULL(tii.activityid,0) 
	LEFT JOIN #timesheetnondeliveryinsertInfratickets TDI ON TDI.projectid !=ts.projectid
	LEFT JOIN #ProjectsSupportType PST ON ts.ProjectID=PST.projectid 
	AND  iscognizant=1  --AND td.timetickerid=ts.timetickerid
	where ts.[Type] = 'ND' AND ts.iscognizant = 1 
	AND ISNULL(PST.IsDevProject,0) =2

	INSERT INTO avl.TM_TRN_InfraTimesheetDetail
	(TimesheetId,TimeTickerID,TowerID,TicketID,IsNonTicket,TaskId,TicketTypeMapID,
	Hours,Remarks,ProjectId,IsDeleted,CreatedBy,CreatedDateTime)
	SELECT DISTINCT ts.timesheetid,0,ts.TowerID,ts.ticketid,Isnull(tii.isnondelivery,0),tii.ActivityID,tm.TicketTypeMapID,ts.totaleffort
	,tm.nonticketdescription,tii.projectid,0,tm.employeeid,getdate()
	FROM #timesheetnondeliveryinsertInfratickets tii
	inner join #timesheettickets ts on tii.timesheetid=ts.timesheetid AND tii.projectid=ts.projectid
  AND tii.isnondelivery=1  AND tii.activityid=ts.activityid
  left join @timesheeteffortmini tm on  tii.activityid=tm.activityid AND tii.projectid=tm.projectid
  --INNER JOIN AVL.TK_TRN_infraTicketDetail(NOLOCK) TD on tii.timetickerid= TD.TimeTickerID   AND tii.projectid=TD.ProjectID
  LEFT JOIN #ProjectsSupportType PST ON ts.ProjectID=PST.projectid
	where ts.[Type] = 'ND' 
	AND  ts.iscognizant= 1 and ISNULL(PST.IsDevProject,0) =2  and tm.employeeid is not null



	UPDATE td set td.hours= case when @mode='Mini' then td.hours + ts.totaleffort
	else ts.totaleffort end ,
	modifiedby=@mode,modifieddatetime=GETDATE(),remarks=ts.nonticketdescription
	FROM avl.tm_trn_timesheetdetail td
	INNER JOIN  #timesheetnondeliveryupdatetickets(NOLOCK) tii on td.timesheetid=tii.timesheetid 
	INNER JOIN #timesheettickets(NOLOCK) ts on tii.timesheetid=ts.timesheetid AND tii.projectid=ts.projectid
	AND td.activityid=tii.activityid AND tii.activityid=ts.activityid AND td.isnonticket=1 
	where ts.iscognizant =0

	UPDATE td set td.hours= case when @mode='Mini' then td.hours + ts.totaleffort
	else ts.totaleffort end ,
	modifiedby=@mode,modifieddatetime=GETDATE(),remarks=ts.nonticketdescription
	FROM avl.tm_trn_timesheetdetail(NOLOCK) td
	INNER JOIN  #timesheetnondeliveryupdatetickets(NOLOCK) tii on td.timesheetid=tii.timesheetid 
	INNER JOIN #timesheettickets(NOLOCK) ts on tii.timesheetid=ts.timesheetid AND tii.projectid=ts.projectid
	AND td.activityid=tii.activityid AND tii.activityid=ts.activityid AND td.isnonticket=1 
	LEFT JOIN #ProjectsSupportType(NOLOCK) PST ON ts.ProjectID=PST.projectid
	where ts.[Type] = 'ND' and ts.iscognizant =1
	AND  ISNULL(PST.IsDevProject,0) =0
	

	UPDATE WITD set WITD.hours= case when @mode='Mini' then WITD.hours + ts.totaleffort
	else ts.totaleffort end ,
	modifiedby=@mode,remarks=ts.nonticketdescription,WITD.ModifiedDate=GETDATE()
	FROM ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) WITD
	INNER JOIN  #timesheetnondeliveryupdateworkitems(NOLOCK) tii on WITD.timesheetid=tii.timesheetid 	
	INNER JOIN #timesheettickets(NOLOCK) ts on tii.timesheetid=ts.timesheetid
	AND WITD.activityid=tii.activityid AND tii.activityid=ts.activityid AND WITD.isnonticket=1 
	LEFT JOIN avl.map_ProjectConfig(NOLOCK) PC ON PC.projectid = ts.projectid 
	LEFT JOIN #ProjectsSupportType(NOLOCK) PST ON ts.ProjectID=PST.projectid
	where ts.[Type] = 'ND' AND ts.iscognizant = 1 
	AND ISNULL(PST.IsDevProject,0) =1

	--UPDATE td SET
	--td.hours= CASE WHEN @mode='Mini' then td.hours + ts.totaleffort
	--ELSE ts.totaleffort END ,
	--modifiedby=ts.employeeid,remarks=ts.nonticketdescription,modifieddatetime=getdate()
	--FROM avl.TM_TRN_InfraTimesheetDetail td
	----inner join  #timesheettickets tii on td.timesheetid=tii.timesheetid --AND td.timetickerid=tii.timetickerid
	--inner join #timesheettickets ts on  td.projectid=ts.projectid  AND td.TaskId=ts.activityid --AND td.timesheetid=ts.timesheetid
	----AND ISNULL(td.serviceid,0)=ISNULL(tii.serviceid,0) AND ISNULL(td.activityid,0)=ISNULL(tii.activityid,0) 
	--LEFT JOIN #ProjectsSupportType PST ON ts.ProjectID=PST.projectid
	--AND  iscognizant=1  AND td.timetickerid=ts.timetickerid
	--where ts.[Type] = 'ND' AND ts.iscognizant = 1 
	--AND ISNULL(PST.IsDevProject,0) =2

	


	SELECT projectid,ticketid,SuggestedActivity,timesheetid,nonticketdescription,Type 
	INTO #SUGGESTEDNONDELIVERY FROM #timesheettickets(NOLOCK) 
	WHERE isnondelivery = 1 and (ISNULL(SuggestedActivity,'') <> '') and activityid =8

	SELECT distinct projectid,SuggestedActivity INTO #SUGGESTEDNONDELIVERY_temp FROM #timesheettickets(NOLOCK) 
	WHERE isnondelivery = 1 and (ISNULL(SuggestedActivity,'') <> '') and activityid =8

	MERGE AVL.TM_NonDeliverySuggestedActivity AS NSA  
	USING #SUGGESTEDNONDELIVERY_temp as tmp  
  
	ON tmp.SuggestedActivity = NSA.SuggestedActivityName and tmp.ProjectID = NSA.ProjectID AND NSA.IsDeleted = 0 
  
	WHEN MATCHED THEN  
	UPDATE SET NSA.ModifiedDateTime = GETDATE(), NSA.ModifiedBy = @mode 

	WHEN NOT MATCHED THEN  
  
	INSERT (ProjectID,SuggestedActivityName,IsReviewed,IsDeleted,CreatedBy,CreatedDateTime,ModifiedBy,ModifiedDateTime)  
	VALUES (tmp.projectid,tmp.SuggestedActivity,0,0,@mode,getdate(),null,null);  
	

	UPDATE TD SET TD.SuggestedActivityID = nsg.SuggestedActivityID, TD.Remarks = sd.nonticketdescription
	FROM AVL.TM_TRN_TimesheetDetail(NOLOCK) TD
	INNER JOIN #SUGGESTEDNONDELIVERY(NOLOCK) sd ON SD.timesheetid = TD.TimesheetId AND sd.projectid = TD.ProjectId
	INNER JOIN AVL.TM_NonDeliverySuggestedActivity(NOLOCK) nsg ON NSG.SuggestedActivityName = SD.SuggestedActivity AND nsg.ProjectID = sd.projectid
	WHERE nsg.IsDeleted = 0 and td.ActivityId = 8 and sd.[Type] = 'ND'

	UPDATE TD SET TD.SuggestedActivityID = nsg.SuggestedActivityID, TD.Remarks = sd.nonticketdescription
	FROM ADM.TM_TRN_WorkItemTimesheetDetail(NOLOCK) TD
	INNER JOIN #SUGGESTEDNONDELIVERY(NOLOCK) sd ON SD.timesheetid = TD.TimesheetId 
	INNER JOIN AVL.TM_NonDeliverySuggestedActivity(NOLOCK) nsg ON NSG.SuggestedActivityName = SD.SuggestedActivity AND nsg.ProjectID = sd.projectid
	WHERE nsg.IsDeleted = 0 and td.ActivityId = 8 and sd.[Type] = 'ND'

	UPDATE TD SET TD.SuggestedActivityID = nsg.SuggestedActivityID, TD.Remarks = sd.nonticketdescription
	FROM AVL.TM_TRN_InfraTimesheetDetail TD
	INNER JOIN #SUGGESTEDNONDELIVERY sd ON SD.timesheetid = TD.TimesheetId AND sd.projectid = TD.ProjectId
	INNER JOIN AVL.TM_NonDeliverySuggestedActivity nsg ON NSG.SuggestedActivityName = SD.SuggestedActivity AND nsg.ProjectID = sd.projectid
	WHERE nsg.IsDeleted = 0 and td.TaskId = 8 and sd.[Type] = 'ND'

	
	IF @mode='Mini'
		BEGIN
			UPDATE MS SET MS.IsProcessed=2 
			FROM AVL.TK_Mini_Sessions(NOLOCK) MS
			INNER JOIN @timesheeteffortMini TT
			ON MS.SessionID=TT.SessionID
			WHERE TT.IsProcessed=2

			UPDATE ms set ms.isprocessed=1 FROM avl.tk_mini_sessions(NOLOCK) ms 
			join #timesheettickets ts on ms.sessionid=ts.sessionid
		END
				
	INSERT INTO avl.tk_trn_isattributeupdated
	(timetickerid,projectid,ticketid,mode,isprocessed,isdeleted,createdby,createddate,modifiedby,modifieddate)
	SELECT DISTINCT [timetickerid],[projectid],[ticketid],@mode,0,0,'System',GETDATE(),NULL,NULL 
	FROM @timesheeteffortmini
	WHERE timetickerid >0

	INSERT INTO avl.effortuploadautosubmit		
	(customerid,projectid,submitterid,timesheetdate,isprocessed,isdeleted,createdby,createddate,modifiedby,
	modifieddate)
	SELECT DISTINCT pm.customerid,pm.[projectid],userid,usercreatedtimedate,0,0,'System',GETDATE(),NULL,NULL
	FROM @timesheeteffortmini em
	INNER JOIN avl.mas_projectmaster (NOLOCK) pm
	ON em.projectid=pm.projectid AND pm.isdeleted=0
	DROP TABLE #newtimesheetentry
	DROP TABLE #updatetimesheetentry
	DROP TABLE #timesheetinserttickets
	DROP TABLE #timesheetupdatetickets
	DROP TABLE #timesheetdetailscustomerinsert
	DROP TABLE #timesheetdetailscustomerupdate
	DROP TABLE #timesheetnondeliveryinserttickets
	DROP TABLE #timesheetnondeliveryupdatetickets
    DROP TABLE #timesheetnondeliveryinsertworkitems
	DROP TABLE #timesheetnondeliveryupdateworkitems
	DROP TABLE #timesheetnondeliveryupdateInfra
	DROP TABLE #timesheetnondeliveryinsertInfratickets
	END

	SET NOCOUNT OFF;   		
--	COMMIT TRAN	
	
END TRY
BEGIN CATCH

ROLLBACK TRAN

DECLARE @ErrorMessage VARCHAR(MAX);

SELECT @ErrorMessage = ERROR_MESSAGE()

--INSERT Error

EXEC AVL_InsertError 'AVL.TimesheetSubmitAuto',@ErrorMessage,0,0
			
end catch
end
