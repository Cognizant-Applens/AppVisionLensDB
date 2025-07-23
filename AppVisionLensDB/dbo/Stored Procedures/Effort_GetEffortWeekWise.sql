/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [dbo].[Effort_GetEffortWeekWise] --19100 --2495
@CognizantID VARCHAR(1000)  
    
AS  
BEGIN  
BEGIN TRY
SET NOCOUNT ON;  

--DECLARE @StartDateOfMonth DATE
--DECLARE @CurrentDate DATE;

--SET @StartDateOfMonth=(SELECT DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0))
--SET @CurrentDate=(GETDATE())

--DECLARE @EffortEntry AS TABLE(
--        ID int IDENTITY(1,1),
--		TimeSheetDate Date,
--		Effort Decimal(10,2),
--		NonEffort Decimal(10,2) NULL	
--	)

--DECLARE @NonEffortEntry AS TABLE(
--		ID int IDENTITY(1,1),
--		TimeSheetDate Date,
--		NonEffort Decimal(10,2)	
--	)


--         INSERT INTO @EffortEntry SELECT  PT.TimesheetDate  AS TimesheetDate, SUM(TD.Hours) AS Effort,NULL AS NonEffort
--                FROM AVL.TM_PRJ_Timesheet PT
--                INNER JOIN AVL.TM_TRN_TimesheetDetail TD ON PT.TimesheetId=TD.TimesheetId
--				--INNER JOIN [AVL].[MAS_LoginMaster] ML ON ML.EmployeeID=PT.CreatedBy             
--                WHERE 
--				-- ML.EmployeeID=@EmployeeID AND
--				 PT.SubmitterId IN(SELECT UserID FROM [AVL].[MAS_LoginMaster] WHERE EmployeeID=@EmployeeID)
--				 AND  (TD.IsNonTicket Is NULL OR TD.IsNonTicket=0)
--               --and TimesheetDate >=@StartDateOfMonth 
--               --AND TimesheetDate < @CurrentDate
--               GROUP BY PT.TimesheetDate
			    
--         INSERT INTO @NonEffortEntry SELECT  PT.TimesheetDate  AS TimesheetDate, SUM(TD.Hours) AS NonEffort
--                FROM AVL.TM_PRJ_Timesheet PT
--                INNER JOIN AVL.TM_TRN_TimesheetDetail TD ON PT.TimesheetId=TD.TimesheetId
--				--INNER JOIN [AVL].[MAS_LoginMaster] ML ON ML.EmployeeID=PT.CreatedBy             
--                WHERE
--				-- ML.EmployeeID=@EmployeeID AND
--				 PT.SubmitterId IN(SELECT UserID FROM [AVL].[MAS_LoginMaster] WHERE EmployeeID=@EmployeeID)
--				 AND TD.IsNonTicket=1
--                --and TimesheetDate >=@StartDateOfMonth 
--                --AND TimesheetDate < @CurrentDate
--                GROUP BY PT.TimesheetDate 

--      SELECT E.TimeSheetDate,E.Effort,NE.NonEffort FROM @EffortEntry AS E 
--		                                LEFT JOIN  @NonEffortEntry NE ON E.TimeSheetDate=NE.TimeSheetDate

--SELECT * FROM AVL.TM_PRJ_Timesheet 
--SELECT * FROM AVL.TM_TRN_TimesheetDetail

SELECT  SUM(TD.Hours) AS Effort,PT.TimesheetDate AS TimesheetDate FROM AVL.TM_PRJ_Timesheet PT
INNER JOIN AVL.TM_TRN_TimesheetDetail TD
ON PT.TimesheetId=TD.TimesheetId
WHERE PT.SubmitterId='471742'
GROUP BY PT.TimesheetDate 

SET NOCOUNT OFF;  
END TRY  
BEGIN CATCH  
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		EXEC AVL_InsertError '[dbo].[Effort_GetEffortWeekWise] ', @ErrorMessage, @CognizantID,0
	END CATCH  
END
