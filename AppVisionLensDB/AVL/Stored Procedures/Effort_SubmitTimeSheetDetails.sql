/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/



CREATE PROCEDURE [AVL].[Effort_SubmitTimeSheetDetails]
@EmployeeID nvarchar(50),
@Status varchar(50),
@TVP_TicketDetailsCollection TVP_EffortTimesheetTicketDetailsSubmit READONLY	                


AS
BEGIN
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON;  
                       
	--SELECT * FROM @TVP_TicketDetailsCollection
	CREATE TABLE #TicketDetails
	(
	id BIGINT IDENTITY(1,1),
	[TicketID] [nvarchar](max) NULL,
	[ProjectID] [bigint] NULL,
	[ApplicationID] [bigint] null,
	[ServiceID] [bigint] NULL,
	[CategoryID] [bigint] NULL,
	[ActivityID] [bigint] NULL,
	[StatusID] [bigint] null,
	[SubmitterID] [int] null,
	[TimeSheetDate] DATETIME null,
	[EffortHours] [Decimal] null,
	IsNonTicket NVARCHAR(10) NULL,
	TimesheetId NVARCHAR(max) NULL,
	TimeSheetDetailId NVARCHAR(max) NULL,	
	)
	INSERT INTO #TicketDetails
	SELECT TicketID,ProjectID,[ApplicationID],ServiceID,CategoryID,[ActivityID],[StatusID],
	[SubmitterID],[TimeSheetDate],[EffortHours],IsNonTicket,TimesheetId,TimeSheetDetailId
	FROM @TVP_TicketDetailsCollection

UPDATE #TicketDetails SET IsNonTicket=0 WHERE IsNonTicket='N'
UPDATE #TicketDetails SET IsNonTicket=1 WHERE IsNonTicket='Y'
	select *  FROM #TicketDetails
	select DISTINCT ProjectID,SubmitterID,TimeSheetDate,TimesheetId into #Distinct from #TicketDetails

	CREATE TABLE #SaveTimesheet
	(ProjectID BIGINT NULL,
	SubmitterID BIGINT NULL,
	TimeSheetDate DATE NULL,
	StatusID BIGINT NULL,
	CreatedBy NVARCHAR(100) NULL,
	CreatedDateTime  DATETIME NULL,
	TimesheetId   BIGINT NULL)

	if(@status='Save')
	BEGIN
	
	INSERT INTO #SaveTimesheet
	 select ProjectID,SubmitterID,TimeSheetDate,1 as StatusID,@EmployeeID as CreatedBy,getdate()
	  as CreatedDateTime,TimesheetId  
	  from #Distinct
	  SELECT 'save'
	  END
	ELSE IF(@status='Submit')
	BEGIN
	 INSERT INTO #SaveTimesheet
	 select ProjectID,SubmitterID,TimeSheetDate,2 as StatusID,@EmployeeID as CreatedBy,getdate()
	  as CreatedDateTime,TimesheetId  
	  from #Distinct
	  SELECT 'Submit'
	  END
SELECT * FROM #SaveTimesheet

	--Insert If the Record does not Exists checks based on projectID,SubmitterId and TimesheetDate into TimeSheet table
	 insert into AVL.TM_PRJ_Timesheet
	 (ProjectID,
	 SubmitterId,
	 TimesheetDate,
	 StatusId,
	 CreatedBy,
	 CreatedDateTime)
	 select TempTS.ProjectID,TempTS.SubmitterID,TempTS.TimeSheetDate,TempTS.StatusID,
	 TempTS.CreatedBy,TempTS.CreatedDateTime from #SaveTimesheet TempTS
	 WHERE  NOT EXISTS (SELECT 1 FROM AVL.TM_PRJ_Timesheet TS1 
	 WHERE TempTS.ProjectID=TS1.ProjectID and TempTS.SubmitterID=TS1.SubmitterId 
	 and TempTS.TimeSheetDate=TS1.TimesheetDate)


	 select TempTS.ProjectID,TempTS.SubmitterID,TempTS.TimeSheetDate,TempTS.StatusID,
	 TempTS.CreatedBy,TempTS.CreatedDateTime from #SaveTimesheet TempTS
	 WHERE NOT EXISTS(SELECT TS1.TimeSheetDate FROM AVL.TM_PRJ_Timesheet TS1 
	 WHERE TempTS.ProjectID=TS1.ProjectID and TempTS.SubmitterID=TS1.SubmitterId 
	 and TempTS.TimeSheetDate=TS1.TimesheetDate)

	--Updates If the Record Exists checks based on projectID,SubmitterIda and TimesheetDate into TimeSheet table
	 UPDATE TS
	SET StatusId=SaveTS.StatusID,
	[ModifiedBy]  = @EmployeeID,
    ModifiedDateTime  = GetDate()
	FROM AVL.TM_PRJ_Timesheet TS 
	INNER JOIN #TicketDetails TempTD ON TS.TimesheetId=TempTD.TimesheetId
	INNER JOIN #SaveTimesheet SaveTS on SaveTS.TimesheetId=ts.TimesheetId


	UPDATE TSD
	SET 
	ApplicationID=TempTD.ApplicationID,
	ServiceId=TempTD.ServiceID,
	CategoryId=TempTD.CategoryID,
	ActivityId=TempTD.ActivityID,
	Hours=TempTD.EffortHours,
	[ModifiedBy]  = @EmployeeID,
	ModifiedDateTime  = GetDate()
	FROM AVL.TM_TRN_TimesheetDetail TSD 
	INNER JOIN #TicketDetails TempTD ON TSD.TimesheetId=TempTD.TimesheetId
	AND TSD.TimeSheetDetailId=TempTD.TimeSheetDetailId
	--where NOT EXISTS(SELECT 1 FROM AVL.TM_PRJ_Timesheet TS1 
	-- WHERE TempTS.ProjectID=TS1.ProjectID and TempTS.SubmitterID=TS1.SubmitterId 
	-- and TempTS.TimeSheetDate=TS1.TimesheetDate)

	SELECT 'TRN_TimesheetDetail INSERT'


	insert into AVL.TM_TRN_TimesheetDetail
	(TimesheetId,
	ApplicationID,
	TicketID,
	ServiceId,
	CategoryId,
	ActivityId,
	Hours,
	IsNonTicket,
	ProjectId,
	CreatedBy,
	CreatedDateTime)
	select TS.TimesheetId,TD.ApplicationID,TD.TicketID,TD.ServiceID,TD.CategoryID,TD.ActivityID,TD.EffortHours,
	TD.IsNonTicket,TD.ProjectID,@EmployeeID,GETDATE() from #TicketDetails TD 
	left JOIN AVL.TM_PRJ_Timesheet TS on TS.ProjectID=td.ProjectID and TS.SubmitterId=TD.SubmitterID 
	and TS.TimesheetDate=TD.TimeSheetDate 
	where NOT EXISTS (SELECT 1 FROM AVL.TM_TRN_TimesheetDetail TSD 
	 WHERE TSD.TimeSheetDetailId=TD.TimeSheetDetailId and TSD.TimesheetId=TD.TimesheetId)
	--where TD.TimeSheetDetailId = ''

	select TS.TimesheetId,TD.ApplicationID,TD.TicketID,TD.ServiceID,TD.CategoryID,TD.ActivityID,TD.EffortHours,
	TD.IsNonTicket,TD.ProjectID,@EmployeeID,TD.TimeSheetDate from #TicketDetails TD 
	left JOIN AVL.TM_PRJ_Timesheet TS on TS.ProjectID=td.ProjectID and TS.SubmitterId=TD.SubmitterID 
	and TS.TimesheetDate=TD.TimeSheetDate 
	where TD.TimeSheetDetailId = ''


	select sum(TSD.EffortHours) as EffortTilldate ,TSD.TicketID as TicketID,TSD.ProjectID as ProjectID,
	TSD.SubmitterID as SubmitterID into #TempEffortHours 
	from #TicketDetails TSD GROUP by TSD.TicketID ,TSD.ProjectID,TSD.SubmitterID

	 UPDATE TD
	SET EffortTillDate  = TEF.EffortTilldate,
	ServiceID=TempTD.ServiceID,
	TicketStatusMapID=TempTD.StatusID,
	ModifiedBy=@EmployeeID,
   ModifiedDate  = GetDate()
	FROM AVL.TK_TRN_TicketDetail TD 
	INNER JOIN #TicketDetails TempTD ON  TempTD.TicketID=TD.TicketID and TempTD.ProjectID=TD.ProjectID and TempTD.SubmitterID=TD.AssignedTo --and TempTD.TimeSheetDate=TD.TimesheetDate
	join #TempEffortHours TEF on TEF.TicketID=TD.TicketID and TEF.ProjectID=TD.ProjectID and TEF.SubmitterID=TD.AssignedTo
	
	DROP TABLE #TicketDetails

	
SET NOCOUNT OFF; 
COMMIT TRAN
     END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Effort_SubmitTimeSheetDetails] ', @ErrorMessage, @EmployeeID,0
		
	END CATCH  
END
