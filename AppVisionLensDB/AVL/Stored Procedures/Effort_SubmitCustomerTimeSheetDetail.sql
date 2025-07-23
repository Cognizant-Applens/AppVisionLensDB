/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--drop PROCEDURE [dbo].[Effort_SubmitCustomerTimeSheetDetails]
CREATE PROCEDURE [AVL].[Effort_SubmitCustomerTimeSheetDetail]
@EmployeeID nvarchar(1000),
@Status nvarchar(50),
@TVP_TicketDetailsCollection1 TVP_CustomerEffortTimesheetDetailsSubmit1 READONLY	                


AS
BEGIN
BEGIN  TRY
BEGIN TRAN
SET NOCOUNT ON;  
                       
	SELECT * FROM @TVP_TicketDetailsCollection1
	CREATE TABLE #TicketDetails
	(
	id BIGINT IDENTITY(1,1),
	[TicketID] [nvarchar](max) NULL,
	[ProjectID] [bigint] NULL,
	[ApplicationID] [bigint] null,
	[TicketTypeMapID] [bigint] NULL,
	[StatusID] [bigint] null,
	[SubmitterID] [int] null,
	[TimeSheetDate] DATETIME null,
	[EffortHours] [Decimal] null,
	[IsNonTicket] NVARCHAR(10) NULL,
	[TimesheetId] NVARCHAR(max) NULL,
	[TimeSheetDetailId] NVARCHAR(max) NULL,
	[IsAttributeUpdated] [int] null		
	)

	INSERT INTO #TicketDetails
	SELECT TicketID,ProjectID,[ApplicationID],[TicketTypeMapID],[StatusID],
	[SubmitterID],[TimeSheetDate],[EffortHours],[IsNonTicket],[TimesheetId],[TimeSheetDetailId],[IsAttributeUpdated]
	FROM @TVP_TicketDetailsCollection1

	--select * into temp1 from @TVP_TicketDetailsCollection 

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


	if(@Status='Save')
	BEGIN
	SELECT 'save'
	INSERT INTO #SaveTimesheet
	 select ProjectID,SubmitterID,TimeSheetDate,1 as StatusID,@EmployeeID as CreatedBy,getdate()
	  as CreatedDateTime,TimesheetId  
	  from #Distinct
	  END
	ELSE
	BEGIN
	SELECT 'submit'
	 INSERT INTO #SaveTimesheet
	 select ProjectID,SubmitterID,TimeSheetDate,2 as StatusID,@EmployeeID as CreatedBy,getdate()
	  as CreatedDateTime,TimesheetId  
	  from #Distinct
	  END
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

	--Updates If the Record Exists checks based on projectID,SubmitterIda and TimesheetDate into TimeSheet table
	
	UPDATE TS
	SET
	 StatusId=TempTD.StatusID,
	 [ModifiedBy]  = @EmployeeID,
    ModifiedDateTime  = GetDate()
	FROM AVL.TM_PRJ_Timesheet TS 
	INNER JOIN #SaveTimesheet TempTD ON 
	TS.TimesheetId=TempTD.TimesheetId and TS.StatusId<>2

	
	UPDATE TSD
	SET 
	ApplicationID=TempTD.ApplicationID,	
	TicketTypeMapID=TempTD.TicketTypeMapID,
	Hours=TempTD.EffortHours,
	[ModifiedBy]  = @EmployeeID,
	ModifiedDateTime  = GetDate()
	FROM AVL.TM_TRN_TimesheetDetail TSD 
	INNER JOIN #TicketDetails TempTD ON TSD.TimesheetId=TempTD.TimesheetId
	AND TSD.TimeSheetDetailId=TempTD.TimeSheetDetailId

	SELECT 'TRN_TimesheetDetail INSERT'


	insert into AVL.TM_TRN_TimesheetDetail
	(TimesheetId,
	ApplicationID,
	TicketID,
	TicketTypeMapID,
	Hours,
	IsNonTicket,
	ProjectId,
	CreatedBy,
	CreatedDateTime)
	select TS.TimesheetId,TD.ApplicationID,TD.TicketID,TD.TicketTypeMapID,TD.EffortHours,
	TD.IsNonTicket,TD.ProjectID,@EmployeeID,TD.TimeSheetDate from #TicketDetails TD 
	left JOIN AVL.TM_PRJ_Timesheet TS on TS.ProjectID=td.ProjectID and TS.SubmitterId=TD.SubmitterID 
	and TS.TimesheetDate=TD.TimeSheetDate 
	where NOT EXISTS (SELECT 1 FROM AVL.TM_TRN_TimesheetDetail TSD 
	 WHERE TSD.TimeSheetDetailId=TD.TimeSheetDetailId and TSD.TimesheetId=TD.TimesheetId)

	select TS.TimesheetId,TD.ApplicationID,TD.TicketID,TD.EffortHours,
	TD.IsNonTicket,TD.ProjectID,@EmployeeID,TD.TimeSheetDate from #TicketDetails TD 
	left JOIN AVL.TM_PRJ_Timesheet TS on TS.ProjectID=td.ProjectID and TS.SubmitterId=TD.SubmitterID 
	and TS.TimesheetDate=TD.TimeSheetDate 
	where TD.TimeSheetDetailId = ''

	select sum(TSD.EffortHours) as EffortTilldate ,TSD.TicketID as TicketID,TSD.ProjectID as ProjectID,
	TSD.SubmitterID as SubmitterID into #TempEffortHours 
	from #TicketDetails TSD GROUP by TSD.TicketID ,TSD.ProjectID,TSD.SubmitterID

	 UPDATE TD
	SET EffortTillDate  = TEF.EffortTilldate,
	TicketTypeMapID=TempTD.TicketTypeMapID,
	TicketStatusMapID=TempTD.StatusID,
	IsAttributeUpdated=TempTD.IsAttributeUpdated,
	ModifiedBy=@EmployeeID,
   ModifiedDate  = GetDate()
	FROM AVL.TK_TRN_TicketDetail TD 
	INNER JOIN #TicketDetails TempTD ON  TempTD.TicketID=TD.TicketID and TempTD.ProjectID=TD.ProjectID and TempTD.SubmitterID=TD.AssignedTo --and TempTD.TimeSheetDate=TD.TimesheetDate
	join #TempEffortHours TEF on TEF.TicketID=TD.TicketID and TEF.ProjectID=TD.ProjectID and TEF.SubmitterID=TD.AssignedTo
	
	DROP TABLE #TicketDetails

--===========================================================================================

SET NOCOUNT OFF; 
     COMMIT TRAN
	 END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()
		ROLLBACK TRAN
		--INSERT Error    
		EXEC AVL_InsertError '[AVL].[Effort_SubmitCustomerTimeSheetDetail]', @ErrorMessage, @EmployeeID,0
		
	END CATCH  
END
