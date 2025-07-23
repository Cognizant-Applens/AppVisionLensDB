
CREATE PROCEDURE [AVL].[DefaulterforMyActivity] 
(
@StartDate date,
@EndDate date = null,
@IsDaily int,
@IsCognizant int
)
AS
BEGIN
BEGIN TRY
IF (@IsDaily = 1)
BEGIN

		select Ts.TimesheetID,PM.EsaProjectID,LM.EmployeeID,TS.Timesheetdate,TS.StatusID,CM.CustomerName,PM.ProjectID,CM.CustomerID from [AVL].[TM_PRJ_Timesheet] TS
		JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = Ts.ProjectID
		JOIN [AVL].[Customer] CM on CM.CustomerID = TS.CustomerID
		JOIN [AVL].[MAS_LoginMaster] LM on LM.UserID = TS.SubmitterID
		where CM.IsDaily = @IsDaily and TS.Timesheetdate = CAST(@StartDate AS date) and TS.statusID in (1,3,4,5,6) and cm.IsCognizant = @IsCognizant

END
ELSE
BEGIN
		select Ts.TimesheetID,PM.EsaProjectID,LM.EmployeeID,TS.Timesheetdate,TS.StatusID,CM.CustomerName,PM.ProjectID,CM.CustomerID from [AVL].[TM_PRJ_Timesheet] TS
		JOIN [AVL].[MAS_ProjectMaster] PM on PM.ProjectID = Ts.ProjectID
		JOIN [AVL].[Customer] CM on CM.CustomerID = TS.CustomerID
		JOIN [AVL].[MAS_LoginMaster] LM on LM.UserID = TS.SubmitterID
		where CM.IsDaily = @IsDaily and TS.Timesheetdate between CAST(@StartDate AS date) and CAST(@EndDate AS date) 
		and TS.statusID in (1,3,4,5,6) and cm.IsCognizant = @IsCognizant
END 
--DROP TABLE #TicketDetailsTEMP
SET NOCOUNT OFF;
 END TRY  
   BEGIN CATCH  
              DECLARE @ErrorMessage VARCHAR(MAX);
              SELECT @ErrorMessage = ERROR_MESSAGE()
              --Insert Error    
              EXEC AVL_InsertError '[AVL].[DefaulterforMyActivity]', @ErrorMessage, 0, 0
              RETURN @@ERROR       
   END CATCH 
END
