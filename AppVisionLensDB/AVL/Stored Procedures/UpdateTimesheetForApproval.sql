/***************************************************************************  
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET  
*Copyright [2018] – [2021] Cognizant. All rights reserved.  
*NOTICE: This unpublished material is proprietary to Cognizant and  
*its suppliers, if any. The methods, techniques and technical  
  concepts herein are considered Cognizant confidential and/or trade secret information.   
    
*This material may be covered by U.S. and/or foreign patents or patent applications.   
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.  
***************************************************************************/  
  
/*-- =============================================  
-- Author:  Sreeya  
-- Create date: 22-1-2018  
-- Description: modified Sp to add My task features  
-- =============================================*/  
  
CREATE Procedure [AVL].[UpdateTimesheetForApproval]  
@ApproveUnfreezeTimesheet AVL.AVL_ApproveUnfreezeTimesheet readonly,  
@CustomerID bigint  
AS  
BEGIN  
BEGIN TRY  
 SET NOCOUNT ON;  
 DECLARE @result bit   
  
  
  
  
DECLARE @AVL_ApproveUnfreezeTimesheetTemp AS TABLE(  
 [EmployeeID] [nvarchar](50) NULL,  
 [TimeSheetDate] [datetime] NULL,  
 [TimesheetId] [int] NULL,  
 [IsApproval] [bit] NULL,  
 [StatusId] [int] NULL,  
 [SubmitterID] [nvarchar](50) NULL,  
 [Comments] [nvarchar](100) NULL,  
 TimesheetCount INT DEFAULT 0  
)  
  
  
  
INSERT INTO @AVL_ApproveUnfreezeTimesheetTemp  
(EmployeeID,TimeSheetDate,TimesheetId,IsApproval,StatusId,SubmitterID,Comments,TimesheetCount)  
SELECT distinct T1.EmployeeID,T1.TimeSheetDate,T1.TimesheetId,T1.IsApproval,T1.StatusId,T1.SubmitterID,T1.Comments, COUNT(DISTINCT TS.TimesheetId) TimesheetCount  
FROM @ApproveUnfreezeTimesheet T1   
INNER JOIN AVL.MAS_LoginMaster LM ON LM.EmployeeID=T1.SubmitterID AND LM.CustomerID=@CustomerID AND LM.IsDeleted=0  
LEFT JOIN AVL.TM_PRJ_Timesheet TS  
ON TS.CustomerID=@CustomerID AND TS.TimesheetDate = T1.TimeSheetDate AND TS.SubmitterId=LM.UserID  
GROUP BY T1.EmployeeID,T1.TimeSheetDate,T1.TimesheetId,T1.IsApproval,T1.StatusId,T1.SubmitterID,T1.Comments  
  
  
  
 UPDATE TS1 SET   
StatusId=4,  
ModifiedBy=LM.TSApproverId,  
UnfreezedBy=LM.TSApproverId,  
UnfreezedDate=GETDATE(),  
ModifiedDateTime=GETDATE()  
 FROM AVL.TM_PRJ_Timesheet TS1  
JOIN @ApproveUnfreezeTimesheet t2 ON TS1.TimesheetDate=T2.TimesheetDate  
JOIN AVL.MAS_LoginMaster LM ON LM.EmployeeID=T2.SubmitterID AND LM.UserID=TS1.SubmitterId AND LM.IsDeleted=0  
AND TS1.CustomerID=@CustomerID AND t2.StatusId=4;  
  
 UPDATE TS1 SET   
 StatusId=3,  
  ModifiedBy=LM.TSApproverId,  
  ApprovedBy=LM.TSApproverId,  
  ApprovedDate=GETDATE(),  
ModifiedDateTime=GETDATE()  
 FROM AVL.TM_PRJ_Timesheet TS1  
JOIN @ApproveUnfreezeTimesheet t2 ON TS1.TimesheetDate=T2.TimesheetDate  
JOIN AVL.MAS_LoginMaster LM ON LM.EmployeeID=T2.SubmitterID AND LM.UserID=TS1.SubmitterId AND LM.IsDeleted=0  
AND TS1.CustomerID=@CustomerID AND t2.StatusId=3;  
  
  
  
  
INSERT INTO AVL.TM_PRJ_Timesheet  
(ProjectID,CustomerID, SubmitterId,TimesheetDate,StatusId,ApprovedBy,UnfreezedBy,UnfreezedDate,  
CreatedBy,CreatedDateTime  
,ModifiedBy,ModifiedDateTime,IsAutosubmit,RejectionComments,ApprovedDate,TSRegion,IsNonTicket)  
SELECT   
DISTINCT  
LM.ProjectID ,  
@CustomerID  
,LM.UserID  
,T2.TimeSheetDate  
,4  
,NULL  
,LM.TSApproverId  
 ,GETDATE()  
,LM.TSApproverId  
,GETDATE()  
,NULL  
,NULL  
,0  
,T2.Comments  
,NULL  
,NULL  
,0  
FROM @AVL_ApproveUnfreezeTimesheetTemp T2 INNER JOIN AVL.MAS_LoginMaster LM  
 ON LM.EmployeeID = T2.SubmitterID  AND LM.CustomerID=@CustomerID  
WHERE T2.TimesheetCount=0  and LM.IsDeleted=0 AND t2.StatusId=4  
  
  
--inserting into EmailCollection Table  
--Insert INTO AVL.EmailCollection  
--(ToAddress,CC,Bcc,Scenario,Subject,FilePath,Status,Body,Date)  
-- SELECT   
--distinct LM.EmployeeEmail  
--,LM.EmployeeEmail  
--,null  
--,1  
--,'Your timesheet has been unfrozen.'  
--,''  
--,0  
--,'Dear '+LM.EmployeeName +',/n  
--Your timesheet for the date '+CONVERT(VARCHAR(10), T2.TimeSheetDate, 120) +' has been unfrozen. Please submit the same ASAP without fail.  
--Project Details:{1} - {2}/n  
--Ps: This is system generated mail, Please do not reply to this mail.'  
--,T2.TimeSheetDate  
--FROM @AVL_ApproveUnfreezeTimesheetTemp T2 INNER JOIN AVL.MAS_LoginMaster LM  
-- ON LM.EmployeeID = T2.SubmitterID  AND LM.CustomerID=@CustomerID  
--WHERE T2.TimesheetCount=0  and LM.IsDeleted=0  AND t2.StatusId=4  
  
  
SET CONCAT_NULL_YIELDS_NULL OFF  
IF EXISTS(SELECT 1 FROM @AVL_ApproveUnfreezeTimesheetTemp)  
BEGIN  
DECLARE @TaskApplication varchar(200),@TaskStatus varchar(100),@TaskID int  
,@TaskName varchar(300) , @TaskType varchar(200),@TaskURL varchar(max),@ESA varchar(50),@Cname varchar(max);  
SELECT @TaskApplication= ApplicationName FROM TaskApplication Where TaskID=5 AND IsDeleted=0;  
SELECT @TaskStatus= Status FROM TaskStatus Where IsDeleted=0 AND  TaskStatusID=1;  
SELECT @TaskName= TaskName FROM TaskMaster Where TaskID=5;  
SELECT @TaskType= TaskType FROM Tasktype Where  TaskTypeID=1 AND IsDeleted=0;  
SELECT @TaskURL= TaskURL FROM TaskURL Where  TaskID=5 and IsDeleted=0;  
SELECT @ESA=ESA_AccountID,@Cname=CustomerName FROM AVL.Customer Where  CustomerID=@CustomerID and IsDeleted=0;  
IF EXISTS(SELECT 1 FROM AVL.Customer where customerid=@CustomerID and IsDaily=1)  
BEGIN  
  
SELECT   
 SubmitterID,  
  MIN([TimeSheetDate]) as StartDate,   
  MAX([TimeSheetDate]) as EndDate ,  
  Comments  
INTO #TimeSheetTask  
FROM   
 (  
  SELECT   
   *,   
   ROW_NUMBER() OVER(PARTITION BY SubmitterID,Comments ORDER BY [TimeSheetDate] asc) as ranking   
   from @AVL_ApproveUnfreezeTimesheetTemp WHERE StatusID=4  
 ) t    
 group by   
   SubmitterID, (CAST([TimeSheetDate] AS INT)-Ranking),Comments  
order by   
   SubmitterID, (CAST([TimeSheetDate] AS INT)-Ranking)  
  
  
SELECT DISTINCT T.SubmitterID AS 'UserID',@TaskApplication AS 'Application','2' AS 'ExpiryAfterRead',  
'N' AS 'Read',@TaskStatus AS 'Status',5 AS 'TaskID',@TaskName AS 'TaskName',@TaskType AS 'TaskType',  
@TaskURL AS 'TaskURL',CASE WHEN DATEPART(DAY,T.StartDate)=DATEPART(DAY,T.EndDate)  
THEN  
 'Timesheet has been Unfrozen for the Account '+@ESA +' - '+@Cname+ ' for the Period ' + CONVERT(VARCHAR(10), T.StartDate, 101)   
+ '  | Rejection Comments : ' + T.Comments  
 ELSE   
 'Timesheet has been Unfrozen for the Account '+@ESA +' - '+@Cname+ ' for the Period ' + CONVERT(VARCHAR(10),T.StartDate, 101)  
+' to ' + CONVERT(VARCHAR(10),T.EndDate, 101) + '  | Rejection Comments : ' + T.Comments   
 END AS 'TaskDetails'  
 FROM #TimeSheetTask T JOIN avl.MAS_LoginMaster LM  
ON LM.EmployeeID=T.SubmitterID AND LM.CustomerID=@CustomerID and LM.IsDeleted=0;  
  
  
END  
ELSE  
BEGIN  
DECLARE @mindate varchar(max),@maxdate varchar(max);  
select  @mindate=MIN(CONVERT(VARCHAR(10), T.TimeSheetDate, 101)),@maxdate=MAX(CONVERT(VARCHAR(10), T.TimeSheetDate, 101)) from @AVL_ApproveUnfreezeTimesheetTemp T;  
print 5;  
SELECT DISTINCT LM.EmployeeID AS 'UserID',@TaskApplication AS 'Application','2' AS 'ExpiryAfterRead',  
'N' AS 'Read',@TaskStatus AS 'Status',5 AS 'TaskID',@TaskURL AS 'TaskURL',@TaskName AS 'TaskName',@TaskType AS 'TaskType',  
'Timesheet has been Unfrozen for the Account '+@ESA +' - '+@Cname+ ' for the Period ' + @mindate  
+' to ' + @maxdate + '  | Rejection Comments : ' + T.Comments  AS 'TaskDetails'  
 FROM @AVL_ApproveUnfreezeTimesheetTemp T JOIN avl.MAS_LoginMaster LM  
ON LM.EmployeeID=T.SubmitterID AND LM.CustomerID=@CustomerID AND   T.TimesheetCount=0 and LM.IsDeleted=0 AND T.StatusId=4;  
END  
END  
SET CONCAT_NULL_YIELDS_NULL ON  
  
  
END TRY  
BEGIN CATCH  
  
 DECLARE @ErrorMessage VARCHAR(MAX);  
  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
  
 --INSERT Error  
  
 EXEC AVL_InsertError 'AVL.UpdateTimesheetForApproval',@ErrorMessage,0,0  
     
END CATCH  
END  