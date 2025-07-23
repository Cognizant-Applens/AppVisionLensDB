/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [AVL].[DeleteTicketfrmGrid]
@EmployeeID NVARCHAR(100),
@CustomerID BIGINT,
@ProjectID BIGINT,
@TicketID NVARCHAR(100),
@ServiceID VARCHAR(50),
@ActivityID INT,
@TimeTickerID BIGINT,
@FirstDateOfWeek DATE,
@LastDateOfWeek DATE,
@SubmitterID NVARCHAR(100)=NULL,
@Hours VARCHAR(50),
@TickSupportTypeID INT,
@Type varchar(10)


AS
BEGIN
BEGIN TRY
BEGIN TRAN
SET NOCOUNT ON;

DECLARE @UserID NVARCHAR(100);
DECLARE @MinusHours decimal(10,2);
DECLARE @EffortToUpdate decimal(10,2);
DECLARE @EffortTilldate decimal(10,2);
SET @UserID=(SELECT UserID FROM AVL.MAS_LoginMaster(NOLOCK) WHERE EmployeeID=@EmployeeID AND CustomerID=@CustomerID
AND ProjectID=@ProjectID AND IsDeleted = 0);

---------UPDATE ISDELETED=1 IN TIMESHEETDETAILS----------- 
IF(@Type = 'W')
BEGIN

 SELECT TD.Hours INTO #TmpEffortHours2
FROM [ADM].[TM_TRN_WorkItemTimesheetDetail] TD with(NOLOCK) JOIN
AVL.TM_PRJ_Timesheet T with(NOLOCK) ON TD.TimeSheetId=T.TimesheetId
AND T.CustomerID=@CustomerID AND T.SubmitterId=@UserID AND T.ProjectID=@ProjectID
WHERE TD.WorkItemDetailsId=@TimeTickerID AND (T.TimesheetDate>=CONVERT(DATE,@FirstDateOfWeek) AND 
T.TimesheetDate<=CONVERT(DATE,@LastDateOfWeek)) AND T.StatusId IN(1,4) AND TD.ServiceId=@ServiceID AND TD.ActivityId=@ActivityID

SET @MinusHours=(SELECT SUM(Hours) FROM #TmpEffortHours2(NOLOCK));
SET @EffortTilldate=(SELECT WorkProfilerEffort FROM ADM.ALM_TRN_WorkItem_Details(NOLOCK) WHERE WorkItemDetailsId=@TimeTickerID AND Project_Id=@ProjectID AND
WorkItem_Id=@TicketID);
SET @EffortToUpdate=(select @EffortTilldate-isnull(@MinusHours,0))



DELETE TD FROM [ADM].[TM_TRN_WorkItemTimesheetDetail] TD JOIN
AVL.TM_PRJ_Timesheet T with(NOLOCK) ON TD.TimeSheetId=T.TimesheetId
AND T.CustomerID=@CustomerID AND T.SubmitterId=@UserID AND T.ProjectID=@ProjectID
WHERE TD.WorkItemDetailsId=@TimeTickerID AND (T.TimesheetDate>=CONVERT(DATE,@FirstDateOfWeek) AND 
T.TimesheetDate<=CONVERT(DATE,@LastDateOfWeek)) AND T.StatusId IN(1,4) AND TD.ServiceId=@ServiceID AND TD.ActivityId=@ActivityID


----UPDATE THE Actual_Effort IN WorkItem_Details-------------------

UPDATE ADM.ALM_TRN_WorkItem_Details SET WorkProfilerEffort=@EffortToUpdate,ModifiedDate=GETDATE(),ModifiedBy=@EmployeeID WHERE WorkItemDetailsId=@TimeTickerID AND Project_Id=@ProjectID AND
WorkItem_Id=@TicketID


END

ELSE

BEGIN 


IF(@TimeTickerID!=0)
BEGIN
IF(@TickSupportTypeID=2)
BEGIN
 SELECT TD.Hours INTO #TmpEffortHours1
FROM AVL.TM_TRN_InfraTimesheetDetail TD with (NOLOCK) JOIN
AVL.TM_PRJ_Timesheet T (NOLOCK) ON TD.TimesheetId=T.TimesheetId
AND T.CustomerID=@CustomerID AND T.SubmitterId=@UserID AND T.ProjectID=@ProjectID
WHERE TD.TimeTickerID=@TimeTickerID AND (T.TimesheetDate>=CONVERT(DATE,@FirstDateOfWeek) AND 
T.TimesheetDate<=CONVERT(DATE,@LastDateOfWeek)) AND T.StatusId IN(1,4) AND TD.TaskId=@ActivityID

SET @MinusHours=(SELECT SUM(Hours) FROM #TmpEffortHours1(NOLOCK));
SET @EffortTilldate=(SELECT EffortTillDate FROM AVL.TK_TRN_InfraTicketDetail With (NOLOCK) WHERE TimeTickerID=@TimeTickerID AND ProjectID=@ProjectID AND
TicketID=@TicketID);
SET @EffortToUpdate=(select @EffortTilldate-isnull(@MinusHours,0))



DELETE TD FROM AVL.TM_TRN_InfraTimesheetDetail TD JOIN
AVL.TM_PRJ_Timesheet T with(NOLOCK) ON TD.TimesheetId=T.TimesheetId
AND T.CustomerID=@CustomerID AND T.SubmitterId=@UserID AND T.ProjectID=@ProjectID
WHERE TD.TimeTickerID=@TimeTickerID AND (T.TimesheetDate>=CONVERT(DATE,@FirstDateOfWeek) AND 
T.TimesheetDate<=CONVERT(DATE,@LastDateOfWeek)) AND T.StatusId IN(1,4) AND TD.TaskId=@ActivityID



----UPDATE THE EFFORT TILL DATE IN TICKETDETAILS-------------------

UPDATE AVL.TK_TRN_InfraTicketDetail SET EffortTillDate=@EffortToUpdate WHERE TimeTickerID=@TimeTickerID AND ProjectID=@ProjectID AND
TicketID=@TicketID 

----INSERT THE DELETED TICKET INTO [AutoAssigneeExclude] TABLE------

INSERT INTO AVL.AutoAssigneeExcludeInfra (TimeTickerID,TicketID,CustomerID,ProjectID,SubmitterId,TimesheetDate,
StartDate,EndDate,CreatedDate,CreatedBy)
VALUES (@TimeTickerID,@TicketID,@CustomerID,@ProjectID,@UserID,GETDATE(),@FirstDateOfWeek,@LastDateOfWeek,GETDATE(),
@EmployeeID)

END

ELSE
BEGIN
 SELECT TD.Hours INTO #TmpEffortHours
FROM AVL.TM_TRN_TimesheetDetail TD with(NOLOCK) JOIN
AVL.TM_PRJ_Timesheet T with(NOLOCK) ON TD.TimesheetId=T.TimesheetId
AND T.CustomerID=@CustomerID AND T.SubmitterId=@UserID AND T.ProjectID=@ProjectID
WHERE TD.TimeTickerID=@TimeTickerID AND (T.TimesheetDate>=CONVERT(DATE,@FirstDateOfWeek) AND 
T.TimesheetDate<=CONVERT(DATE,@LastDateOfWeek)) AND T.StatusId IN(1,4) AND TD.ServiceId=@ServiceID AND TD.ActivityId=@ActivityID

SET @MinusHours=(SELECT SUM(Hours) FROM #TmpEffortHours(NOLOCK));
SET @EffortTilldate=(SELECT EffortTillDate FROM AVL.TK_TRN_TicketDetail(NOLOCK) WHERE TimeTickerID=@TimeTickerID AND ProjectID=@ProjectID AND
TicketID=@TicketID);
SET @EffortToUpdate=(select @EffortTilldate-isnull(@MinusHours,0))



DELETE TD FROM AVL.TM_TRN_TimesheetDetail TD JOIN
AVL.TM_PRJ_Timesheet T with(NOLOCK) ON TD.TimesheetId=T.TimesheetId
AND T.CustomerID=@CustomerID AND T.SubmitterId=@UserID AND T.ProjectID=@ProjectID
WHERE TD.TimeTickerID=@TimeTickerID AND (T.TimesheetDate>=CONVERT(DATE,@FirstDateOfWeek) AND 
T.TimesheetDate<=CONVERT(DATE,@LastDateOfWeek)) AND T.StatusId IN(1,4) AND TD.ServiceId=@ServiceID AND TD.ActivityId=@ActivityID


----UPDATE THE EFFORT TILL DATE IN TICKETDETAILS-------------------

UPDATE AVL.TK_TRN_TicketDetail SET EffortTillDate=@EffortToUpdate,LastUpdatedDate=GETDATE(),ModifiedDate=GETDATE(),ModifiedBy=@EmployeeID WHERE TimeTickerID=@TimeTickerID AND ProjectID=@ProjectID AND
TicketID=@TicketID 

----INSERT THE DELETED TICKET INTO [AutoAssigneeExclude] TABLE------

INSERT INTO [AVL].[AutoAssigneeExclude] (TimeTickerID,TicketID,CustomerID,ProjectID,SubmitterId,TimesheetDate,
StartDate,EndDate,CreatedDate,CreatedBy)
VALUES (@TimeTickerID,@TicketID,@CustomerID,@ProjectID,@UserID,GETDATE(),@FirstDateOfWeek,@LastDateOfWeek,GETDATE(),
@EmployeeID)

END
END

--------********NON DELIEVERY TICKETS*********-----------
ELSE
BEGIN
IF(@TickSupportTypeID=2)
	BEGIN
	DELETE TD FROM AVL.TM_TRN_InfraTimesheetDetail TD JOIN
	AVL.TM_PRJ_Timesheet T with(NOLOCK) ON TD.TimesheetId=T.TimesheetId
	AND T.CustomerID=@CustomerID AND T.SubmitterId=@UserID AND T.ProjectID=@ProjectID
	WHERE TD.TimeTickerID=@TimeTickerID AND (T.TimesheetDate>=CONVERT(DATE,@FirstDateOfWeek) AND 
	T.TimesheetDate<=CONVERT(DATE,@LastDateOfWeek)) AND T.StatusId IN(1,4) AND TD.TaskId=@ActivityID
	END
ELSE IF(@TickSupportTypeID=0)
	BEGIN
	DELETE TD FROM ADM.TM_TRN_WorkItemTimesheetDetail TD JOIN
	AVL.TM_PRJ_Timesheet T with(NOLOCK) ON TD.TimesheetId=T.TimesheetId
	AND T.CustomerID=@CustomerID AND T.SubmitterId=@UserID AND T.ProjectID=@ProjectID
	WHERE ISNULL(TD.WorkItemDetailsId,0)=@TimeTickerID AND (T.TimesheetDate>=CONVERT(DATE,@FirstDateOfWeek) AND 
	T.TimesheetDate<=CONVERT(DATE,@LastDateOfWeek)) AND T.StatusId IN(1,4) AND TD.ActivityID=@ActivityID
	END

ELSE
	BEGIN
	DELETE TD FROM AVL.TM_TRN_TimesheetDetail TD JOIN
	AVL.TM_PRJ_Timesheet T with(NOLOCK) ON TD.TimesheetId=T.TimesheetId
	AND T.CustomerID=@CustomerID AND T.SubmitterId=@UserID AND T.ProjectID=@ProjectID
	WHERE TD.TimeTickerID=@TimeTickerID AND (T.TimesheetDate>=CONVERT(DATE,@FirstDateOfWeek) AND 
	T.TimesheetDate<=CONVERT(DATE,@LastDateOfWeek)) AND T.StatusId IN(1,4) AND TD.ActivityId=@ActivityID
	END
END
    IF OBJECT_ID('tempdb..#TmpEffortHours2', 'U') IS NOT NULL
	BEGIN
	DROP TABLE #TmpEffortHours2
	END
	IF OBJECT_ID('tempdb..#TmpEffortHours1', 'U') IS NOT NULL
	BEGIN
	DROP TABLE #TmpEffortHours1
	END
	IF OBJECT_ID('tempdb..#TmpEffortHours', 'U') IS NOT NULL
	BEGIN
	DROP TABLE #TmpEffortHours
	END

END
COMMIT TRAN
SET NOCOUNT OFF
END TRY

BEGIN CATCH  
    -- ROLLBACK TRANSCATION 
    ROLLBACK TRAN

    DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT; 

    SELECT @ErrorMessage = ERROR_MESSAGE()
    SELECT @ErrorSeverity = ERROR_SEVERITY()
    SELECT @ErrorState =  ERROR_STATE()

    --INSERT Error    
    EXEC AVL_InsertError '[AVL].[DeleteTicketfrmGrid]', @ErrorMessage,0
                                
    -- Use RAISERROR inside the CATCH block to return error  
    -- information about the original error that caused  
    -- execution to jump to the CATCH block.  
    RAISERROR (@ErrorMessage, -- Message text.  
                                        @ErrorSeverity, -- Severity.  
                                        @ErrorState -- State.  
                                        );     
              
END CATCH 

END
