/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

--[dbo].[Effort_GetEffortDataByMonth] '471742','01/2018'
CREATE PROCEDURE [dbo].[Effort_GetEffortDataByMonth]-- 19100 --2495
@CognizantID VARCHAR(1000),
@MonthSelected VARCHAR(1000)  
    
AS  
BEGIN  
BEGIN TRY
SET NOCOUNT ON;  

DECLARE @ClosedTickets INT
DECLARE @TicketedEffort INT;
DECLARE @NonTicketedEffort INT;
DECLARE @Month INT;
DECLARE @Year INT;
declare @FirstDate nvarchar(max);
declare @LastDate nvarchar(max);
set @Month=Cast((SELECT SUBSTRING(@MonthSelected,1,2)) as int)
set @Year=Cast((SELECT SUBSTRING(@MonthSelected,CHARINDEX ('/', @MonthSelected)+1,LEN(@MonthSelected)-CHARINDEX ('/', @MonthSelected))) as int)


set @FirstDate=(select DATEADD(month,@Month-1,DATEADD(year,@Year-1900,0)))

set @LastDate=(select DATEADD(day,-1,DATEADD(month,@Month,DATEADD(year,@Year-1900,0))))

SET @ClosedTickets=(SELECT COUNT(*) FROM AVL.TK_TRN_TicketDetail WHERE AssignedTo IN(SELECT UserID FROM AVL.MAS_LoginMaster
					WHERE EmployeeID= @CognizantID and isdeleted=0) AND Closeddate BETWEEN @FirstDate and @LastDate)

SET @TicketedEffort=(SELECT SUM(TD.Hours) FROM AVL.TM_TRN_TimesheetDetail TD
					INNER JOIN AVL.TM_PRJ_Timesheet TS ON TD.TimesheetId=TS.TimesheetId
					INNER JOIN AVL.MAS_LoginMaster LM ON TD.ProjectID=LM.ProjectID AND TS.SubmitterId=LM.UserID
					WHERE LM.EmployeeID= @CognizantID and LM.isdeleted=0 and TS.TimesheetDate between @FirstDate and @LastDate AND ISNULL(TD.IsNonTicket,0) =0) ;


SET @NonTicketedEffort=(SELECT SUM(TD.Hours) FROM AVL.TM_TRN_TimesheetDetail TD
					INNER JOIN AVL.TM_PRJ_Timesheet TS ON TD.TimesheetId=TS.TimesheetId
					INNER JOIN AVL.MAS_LoginMaster LM ON TD.ProjectID=LM.ProjectID AND TS.SubmitterId=LM.UserID
					WHERE LM.EmployeeID= @CognizantID and LM.isdeleted=0 AND TS.TimesheetDate BETWEEN @FirstDate and @LastDate  AND ISNULL(TD.IsNonTicket,0) =1);


SELECT ISNULL(@ClosedTickets,0) AS ClosedTickets,
ISNULL(@TicketedEffort,0) AS TicketedEffort,
ISNULL(@NonTicketedEffort,0) AS NonTicketedEffort

SET NOCOUNT OFF;  
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[dbo].[Effort_GetEffortDataByMonth] ', @ErrorMessage, 0,@CognizantID
	END CATCH  
END



--select * from AVL.TM_TRN_TimesheetDetail

--select * from AVL.TM_PRJ_Timesheet where TimesheetDate like '2018-01-%' 
