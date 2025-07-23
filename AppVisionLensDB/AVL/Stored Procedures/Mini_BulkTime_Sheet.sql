/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- ============================================================================
-- author:   Dhivya        
-- create date:  Dec 31    
-- description:  Takes data from Mini Sessions and process  
-- appvisionlens
--[AVL].[Mini_BulkTime_Sheet] 
-- ============================================================================ 
CREATE procedure [AVL].[Mini_BulkTime_Sheet] 
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON
	 DECLARE @tvpforbulkinsert  [avl].[tvp_savetimesheetdetails]

	INSERT INTO @tvpforbulkinsert
	([sessionid],[userid], [projectid], [ticketid] ,
	[ticketdesc] ,[ticketopendate], [applicationid],[serviceid],[activityid], 
	[tickettypemapid],[prioritymapid],[ticketstatusmapid],
	[starttime] ,[endtime],[isauto],[hours],[minutes], [seconds],
	[isprocessed], [employeeid],[requestsource],
	[issdticket],[isnondelivery],[nondeliveryactivitytype],[isdeleted],[createdon],
	[createdby], [modifiedon],[modifiedby],[timetickerid],[isrunning],[nonticketdescription],[usercreatedtimedate],
	[efforts],[SuggestedActivity],[Type])
	SELECT itr.sessionid,itr.userid,itr.projectid,itr.ticketid,
	itr.ticketdesc,itr.ticketopendate,itr.applicationid,itr.serviceid,itr.activityid,
	itr.tickettypemapid,itr.prioritymapid,itr.ticketstatusmapid,
	itr.starttime,itr.endtime,itr.isauto,itr.hours,itr.minutes,itr.seconds,
	itr.isprocessed,itr.employeeid,itr.requestsource,
	itr.issdticket,itr.isnondelivery,itr.nondeliveryactivitytype,itr.isdeleted,itr.createdon,
	itr.createdby,itr.modifiedon,itr.modifiedby,itr.timetickerid,itr.isrunning,itr.nonticketdescription,
	itr.usercreatedtimedate,
	null,SuggestedActivityName,'T'
	FROM avl.tk_mini_sessions itr  With (NOLOCK)
	LEFT JOIN avl.tk_trn_ticketdetail td (NOLOCK) on itr.ticketid=td.ticketid and itr.projectid=td.projectid
	AND  itr.isdeleted=0
	INNER JOIN avl.mas_loginmaster lm (NOLOCK) on lm.employeeid=itr.employeeid and itr.projectid=lm.projectid 
	AND ISNULL(itr.isdeleted,0)=0 and isnull(itr.isprocessed,0) in(0,2)
	AND ISNULL(itr.isrunning,0)=1
	AND CONVERT(date,itr.createdon) >= CONVERT(DATE,GETDATE() -2)
	And itr.IsNonDelivery = 0

	INSERT INTO @tvpforbulkinsert
	([sessionid],[userid], [projectid], [ticketid] ,
	[ticketdesc] ,[ticketopendate], [applicationid],[serviceid],[activityid], 
	[tickettypemapid],[prioritymapid],[ticketstatusmapid],
	[starttime] ,[endtime],[isauto],[hours],[minutes], [seconds],
	[isprocessed], [employeeid],[requestsource],
	[issdticket],[isnondelivery],[nondeliveryactivitytype],[isdeleted],[createdon],
	[createdby], [modifiedon],[modifiedby],[timetickerid],[isrunning],[nonticketdescription],[usercreatedtimedate],
	[efforts],[SuggestedActivity],[Type])
	SELECT itr.sessionid,itr.userid,itr.projectid,itr.ticketid,
	itr.ticketdesc,itr.ticketopendate,itr.applicationid,itr.serviceid,itr.activityid,
	itr.tickettypemapid,itr.prioritymapid,itr.ticketstatusmapid,
	itr.starttime,itr.endtime,itr.isauto,itr.hours,itr.minutes,itr.seconds,
	itr.isprocessed,itr.employeeid,itr.requestsource,
	itr.issdticket,itr.isnondelivery,itr.nondeliveryactivitytype,itr.isdeleted,itr.createdon,
	itr.createdby,itr.modifiedon,itr.modifiedby,itr.timetickerid,itr.isrunning,itr.nonticketdescription,
	itr.usercreatedtimedate,
	null,SuggestedActivityName,'ND'
	FROM avl.tk_mini_sessions itr With (NOLOCK) 
	LEFT JOIN avl.tk_trn_ticketdetail td (NOLOCK) on itr.ticketid=td.ticketid and itr.projectid=td.projectid
	AND  itr.isdeleted=0
	INNER JOIN avl.mas_loginmaster lm (NOLOCK) on lm.employeeid=itr.employeeid and itr.projectid=lm.projectid 
	AND ISNULL(itr.isdeleted,0)=0 and isnull(itr.isprocessed,0) in(0,2)
	AND ISNULL(itr.isrunning,0)=1
	AND CONVERT(date,itr.createdon) >= CONVERT(DATE,GETDATE() -2)
	And itr.IsNonDelivery = 1
	
	CREATE TABLE #SubmittedTimeSheetMini
	(
	SessionID INT NULL,
	TimeSheetDate DATE NULL,
	ProjectID BIGINT NULL,
	CustomerID BIGINT NULL,
	EmployeeID NVARCHAR(100) NULL,
	UserID BIGINT NULL,
	StatusID INT NULL
	)
	CREATE TABLE #SubmittedTimeSheet
	(
	CustomerID BIGINT NULL,
	ProjectID BIGINT NULL,
	TimeSheetDate DATE NULL,
	EmployeeID NVARCHAR(100) NULL,
	UserID BIGINT NULL,
	StatusID INT NULL
	)

	INSERT INTO #SubmittedTimeSheetMini
	select DISTINCT SessionID, CONVERT(DATE,itr.usercreatedtimedate),pm.ProjectID,PM.CustomerID,ITR.employeeid,
	ITR.UserID,
	NULL AS StatusID
	 from @tvpforbulkinsert ITR
	INNER JOIN AVL.MAS_ProjectMaster(NOLOCK) PM
	ON ITR.ProjectID=PM.ProjectID


	CREATE TABLE #ToInsertToTemp
	(
		CustomerID BIGINT NULL,
		ProjectID BIGINT NULL,
		EmployeeID NVARCHAR(100) NULL,
		UserID BIGINT NULL,
		TimeSheetDate DATE NULL
	)

		--Check for projects other than submitted project
		INSERT INTO #ToInsertToTemp 
		SELECT DISTINCT ST.CustomerID, LM.ProjectID,ST.EmployeeID,LM.USERID ,NULL 
		FROM #SubmittedTimeSheetMini  ST With (NOLOCK)
		INNER JOIN  AVL.MAS_LoginMaster(NOLOCK) LM
		ON ST.CustomerID=LM.CustomerID
		WHERE st.EmployeeID=lm.EmployeeID

		UPDATE  TT SET TT.TimeSheetDate=STM.TimeSheetDate FROM  #ToInsertToTemp  TT
		INNER JOIN #SubmittedTimeSheetMini STM
		ON TT.CustomerID=STM.CustomerID --AND TT.ProjectID=STM.ProjectID
		AND TT.EmployeeID=STM.EmployeeID

		INSERT INTO #SubmittedTimeSheet
		select DISTINCT TT.CustomerID,TT.ProjectID,TT.TimesheetDate,TT.EmployeeID,TT.UserID,PT.StatusId from #ToInsertToTemp TT With (NOLOCK)
		INNER JOIN AVL.TM_PRJ_Timesheet(NOLOCK) PT
		ON TT.CustomerID=PT.CustomerID AND TT.ProjectID=PT.ProjectID
		AND TT.UserID=PT.SubmitterId AND TT.TimeSheetDate=PT.TimesheetDate
		select * from #SubmittedTimeSheet

		DELETE TI FROM @tvpforbulkinsert TI
		INNER JOIN #SubmittedTimeSheet ST
		ON TI.EmployeeID=ST.EmployeeID AND CONVERT(DATE,TI.[usercreatedtimedate])=ST.TimeSheetDate
		WHERE ST.StatusID IN(2,3)

		select * from @tvpforbulkinsert
	EXEC  [avl].[timesheetsubmitauto]  @tvpforbulkinsert,'Mini'
	--after submission of timesheet, update is attribute updated flag
	CREATE TABLE  #distinctprojects  
	(
		id BIGINT IDENTITY(1,1),
		projectid BIGINT NULL
	)
	INSERT INTO #distinctprojects
	SELECT DISTINCT projectid from @tvpforbulkinsert

	DECLARE @minid BIGINT;
	DECLARE @maxid BIGINT;
	SET @minid=(select min(id) from #distinctprojects)
	SET @maxid=(select max(id) from #distinctprojects)
	WHILE @minid <= @maxid
		BEGIN
			DECLARE @projectid BIGINT;
			SET @projectid=(SELECT projectid FROM #distinctprojects WHERE id=@minid)
			EXEC  [avl].[effort_updateticketisattributeflagbyproject] @projectid,'Mini'
			SET @minid=@minid +1;
		END
	SET NOCOUNT OFF	
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()
	--INSERT Error
	EXEC AVL_InsertError 'AVL.Mini_BulkTime_Sheet',@ErrorMessage,0,0
			
end catch
end
