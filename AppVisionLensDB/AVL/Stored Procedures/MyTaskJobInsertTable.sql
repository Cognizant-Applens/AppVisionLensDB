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
-- Author:		Sreeya
-- Create date: 22-1-2018
-- Description:	My Task Job table
-- =============================================*/
CREATE PROCEDURE [AVL].[MyTaskJobInsertTable]
@TVP_MyTaskJob AVL.TVP_MyTasks READONLY 
AS
BEGIN
BEGIN TRY

MERGE AVL.MyTaskJob AS TARGET
USING @TVP_MyTaskJob AS SOURCE
ON (Target.AccountID=Source.AccountID AND Target.JobTypeID=Source.JobTypeID AND Target.UserID=Source.UserID)
WHEN NOT MATCHED BY SOURCE 
THEN 
DELETE 
WHEN NOT MATCHED BY TARGET 
THEN 
INSERT (UserID, TaskID, TaskName,URL,TaskDetails,Application,
Status,RefreshedTime,CreatedBy,CreatedTime,ModifiedBy,
ModifiedTime,TaskType,ExpiryDate,Duedate,[Read],
ExpiryAfterRead,AccountID,JobTypeID) 
VALUES (SOURCE.UserID, SOURCE.TaskID, SOURCE.TaskName,Source.URL,Source.TaskDetails,Source.Application,
Source.Status,Source.RefreshedTime,Source.CreatedBy,Source.CreatedTime,Source.ModifiedBy,
Source.ModifiedTime,Source.TaskType,Source.ExpiryDate,Source.Duedate,Source.[Read],
Source.ExpiryAfterRead,Source.AccountID,Source.JobTypeID);

/****DD pending-overdue******/



DECLARE @taskstatusDD varchar(100);
select @taskstatusDD=status from dbo.taskstatus where taskstatusid=2;
UPDATE avl.MyTaskJob set status=@taskstatusDD where TaskID=12 AND CAST(GETDATE() AS DATE)> Duedate;
/***********************/


declare @taskname varchar(500),@taskurl varchar(max),@taskapplication varchar(500),@taskstatus varchar(100),@tasktype as varchar(100) ;
declare @taskid int=9;
select @taskname=taskname from dbo.taskmaster where taskid=@taskid;
select @taskurl=taskurl from dbo.taskurl where taskid=@taskid;
select @taskapplication=applicationname from dbo.taskapplication where taskid=@taskid;
select @taskstatus=status from dbo.taskstatus where taskstatusid=2;
select @tasktype=tasktype from dbo.tasktype where tasktypeid=2;

declare @taskidCL int=11;
declare @tasknameCL varchar(500),@taskurlCL varchar(max),@taskapplicationCL varchar(500);
select @tasknameCL=taskname from dbo.taskmaster where taskid=@taskidCL;
select @taskurlCL=taskurl from dbo.taskurl where taskid=@taskidCL;
select @taskapplicationCL=applicationname from dbo.taskapplication where taskid=@taskidCL;

declare @taskidDD int=12;
declare @tasknameDD varchar(500),@taskurlDD varchar(max),@taskapplicationDD varchar(500);
select @tasknameDD=taskname from dbo.taskmaster where taskid=@taskidDD;
select @taskurlDD=taskurl from dbo.taskurl where taskid=@taskidDD;
select @taskapplicationDD=applicationname from dbo.taskapplication where taskid=@taskidDD;

declare @taskidAH int=15;
declare @tasknameAH varchar(500),@taskurlAH varchar(max),@taskapplicationAH varchar(500);
select @tasknameAH=taskname from dbo.taskmaster where taskid=@taskidAH;
select @taskurlAH=taskurl from dbo.taskurl where taskid=@taskidAH;
select @taskapplicationAH=applicationname from dbo.taskapplication where taskid=@taskidAH;

IF NOT EXISTS(SELECT 1 FROM AVL.MyTaskJob WHERE TaskID=@taskid)
BEGIN
INSERT INTO AVL.MyTaskJob(UserID,TaskID, TaskName, URL, TaskDetails, Application,Status,
 RefreshedTime,CreatedBy,CreatedTime, ModifiedBy, ModifiedTime, ExpiryDate , Duedate, [Read],
 ExpiryAfterRead, AccountID,JobTypeID,TaskType)
VALUES(000000,@taskid,@taskname,@taskurl,'Deletion Record',@taskapplication,@taskstatus,
GETDATE(),'000000',GETDATE(),'000000',GETDATE(),NULL,GETDATE(),'N',0,000000,1,@tasktype)
END

IF NOT EXISTS(SELECT 1 FROM AVL.MyTaskJob WHERE TaskID=@taskidCL)
BEGIN
INSERT INTO AVL.MyTaskJob(UserID,TaskID, TaskName, URL, TaskDetails, Application,Status,
 RefreshedTime,CreatedBy,CreatedTime, ModifiedBy, ModifiedTime, ExpiryDate , Duedate, [Read],
 ExpiryAfterRead, AccountID,JobTypeID,TaskType)
VALUES(000000,@taskidCL,@tasknameCL,@taskurlCL,'Deletion Record',@taskapplicationCL,@taskstatus,
GETDATE(),'000000',GETDATE(),'000000',GETDATE(),NULL,GETDATE(),'N',0,000000,2,@tasktype)
END

IF NOT EXISTS(SELECT 1 FROM AVL.MyTaskJob WHERE TaskID=@taskidDD)
BEGIN
INSERT INTO AVL.MyTaskJob(UserID,TaskID, TaskName, URL, TaskDetails, Application,Status,
 RefreshedTime,CreatedBy,CreatedTime, ModifiedBy, ModifiedTime, ExpiryDate , Duedate, [Read],
 ExpiryAfterRead, AccountID,JobTypeID,TaskType)
VALUES(000000,@taskidDD,@tasknameDD,@taskurlDD,'Deletion Record',@taskapplicationDD,@taskstatus,
GETDATE(),'000000',GETDATE(),'000000',GETDATE(),NULL,GETDATE(),'N',0,000000,3,@tasktype)
END


IF NOT EXISTS(SELECT 1 FROM AVL.MyTaskJob WHERE TaskID=@taskidAH)
BEGIN
INSERT INTO AVL.MyTaskJob(UserID,TaskID, TaskName, URL, TaskDetails, Application,Status,
 RefreshedTime,CreatedBy,CreatedTime, ModifiedBy, ModifiedTime, ExpiryDate , Duedate, [Read],
 ExpiryAfterRead, AccountID,JobTypeID,TaskType)
VALUES(000000,@taskidAH,@tasknameAH,@taskurlAH,'Deletion Record',@taskapplicationAH,@taskstatus,
GETDATE(),'000000',GETDATE(),'000000',GETDATE(),NULL,GETDATE(),'N',0,000000,4,@tasktype)

END


SELECT * FROM AVL.MyTaskJob ;
END TRY
BEGIN CATCH

	DECLARE @ErrorMessage VARCHAR(MAX);

	SELECT @ErrorMessage = ERROR_MESSAGE()

	--INSERT Error

	EXEC AVL_InsertError 'AVL.MyTaskJobInsertTable',@ErrorMessage,0,0
			
END CATCH
END
