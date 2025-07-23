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
-- Create date: 26-12-2018  
-- Description: Gets the user details for ticket upload failure- task list  
-- =============================================*/  
--EXEC [AVL].[TaskListUserTicketUploadFailure] '6837','448351','92198',1  
CREATE PROCEDURE [AVL].[TaskListUserTicketUploadFailure]  
@CustomerID varchar(max),  
@EmployeeID varchar(max),  
@ProjectID varchar(max),  
@IsSharepath BIT,  
@Option int=1  
AS  
BEGIN  
SET NOCOUNT ON;
BEGIN TRY  
DECLARE @TaskApplication varchar(200),@TaskStatus varchar(100),@TaskID int=6  
,@TaskName varchar(300) , @TaskType varchar(200),@TaskURL varchar(max),@TicketUsers varchar(max),@ESAProjectID varchar(max),  
@ProjectName varchar(max),@TaskApplicationSP varchar(200),@TaskIDSP int=18,@TaskURLSP varchar(max),@TaskNameSP varchar(300);  
SELECT @TaskApplication= ApplicationName FROM TaskApplication (NOLOCK) Where TaskID=@TaskID AND IsDeleted=0;  
SELECT @TaskStatus= Status FROM TaskStatus (NOLOCK) Where IsDeleted=0 AND  TaskStatusID=1;  
SELECT @TaskName= TaskName FROM TaskMaster (NOLOCK) Where TaskID=@TaskID;  
SELECT @TaskType= TaskType FROM Tasktype (NOLOCK) Where  TaskTypeID=1 AND IsDeleted=0;  
SELECT @TaskURL= TaskURL FROM TaskURL (NOLOCK) Where  TaskID=@TaskID and IsDeleted=0;  
SELECT @TaskURLSP= TaskURL FROM TaskURL (NOLOCK) Where  TaskID=@TaskIDSP and IsDeleted=0;  
SELECT @TaskApplicationSP= ApplicationName FROM TaskApplication (NOLOCK) Where TaskID=@TaskIDSP AND IsDeleted=0;  
SELECT @TaskNameSP= TaskName FROM TaskMaster (NOLOCK) Where TaskID=@TaskIDSP;  
  
SELECT @ESAProjectID=PM.EsaProjectID,@ProjectName=PM.ProjectName FROM AVL.MAS_ProjectMaster PM (NOLOCK) WHERE PM.ProjectID=@ProjectID;  
  
select @TicketUsers=TicketSharePathUsers from TicketUploadProjectConfiguration (NOLOCK) where ProjectID=@ProjectID AND IsDeleted=0;  
  
SELECT splitdata as 'UserID',@ProjectID AS projectID INTO #tblTicketUsersTemp  
FROM dbo.fnSplitString(@TicketUsers, ';') y  
  
IF @IsSharepath=0  
BEGIN  
IF NOT EXISTS(SELECT 1 FROM #tblTicketUsersTemp (NOLOCK) WHERE UserID=@EmployeeID)  
BEGIN  
INSERT INTO #tblTicketUsersTemp(UserID,ProjectID) Values(@EmployeeID,@ProjectID)  
END  
END  
  
SELECT T.UserID,T.ProjectID INTO #tblTicketUsers FROM #tblTicketUsersTemp T (NOLOCK) JOIN AVL.MAS_LoginMaster LM (NOLOCK)   
ON LM.EmployeeID=T.UserID WHERE LM.ProjectID=@ProjectID AND LM.IsDeleted=0  
  
IF EXISTS(SELECT 1 FROM #tblTicketUsers (NOLOCK))  
BEGIN  
IF @IsSharepath=0  
BEGIN  
IF @Option=1  
BEGIN  
SELECT DISTINCT T.UserID AS 'UserID',@TaskApplication AS 'Application','2' AS 'ExpiryAfterRead',  
'N' AS 'Read',@TaskStatus AS 'Status',@TaskID AS 'TaskID',@TaskName AS 'TaskName',@TaskType AS 'TaskType',  
@TaskURL AS 'TaskURL','Ticket dump upload failed for the Project : ' + @ESAProjectID +' - '+ @ProjectName AS 'TaskDetails'  
 FROM #tblTicketUsers T (NOLOCK);  
 END  
 ELSE  
 BEGIN  
 SELECT DISTINCT T.UserID AS 'UserID',@TaskApplication AS 'Application','2' AS 'ExpiryAfterRead',  
'N' AS 'Read',@TaskStatus AS 'Status',@TaskID AS 'TaskID',@TaskName AS 'TaskName',@TaskType AS 'TaskType',  
@TaskURL AS 'TaskURL','Ticket Uploaded Successfully, Please check error log for failed tickets for the Project : ' + @ESAProjectID +' - '+ @ProjectName AS 'TaskDetails'  
 FROM #tblTicketUsers T (NOLOCK);  
 END  
 END  
 ELSE  
 BEGIN  
 IF @Option=1  
 BEGIN  
 SELECT DISTINCT T.UserID AS 'UserID',@TaskApplicationSP AS 'Application','2' AS 'ExpiryAfterRead',  
'N' AS 'Read',@TaskStatus AS 'Status',@TaskIDSP AS 'TaskID',@TaskNameSP AS 'TaskName',@TaskType AS 'TaskType',  
@TaskURL AS 'TaskURL','Ticket dump share path upload failed for the Project : ' + @ESAProjectID +' - '+ @ProjectName AS 'TaskDetails'  
 FROM #tblTicketUsers T (NOLOCK);  
 END  
 ELSE  
 BEGIN  
  SELECT DISTINCT T.UserID AS 'UserID',@TaskApplicationSP AS 'Application','2' AS 'ExpiryAfterRead',  
'N' AS 'Read',@TaskStatus AS 'Status',@TaskIDSP AS 'TaskID',@TaskNameSP AS 'TaskName',@TaskType AS 'TaskType',  
@TaskURL AS 'TaskURL','Tickets via share path Uploaded Successfully, Please check error log for failed tickets for the Project : ' + @ESAProjectID +' - '+ @ProjectName AS 'TaskDetails'  
 FROM #tblTicketUsers T (NOLOCK);  
 END  
 END  
END  
END TRY  
BEGIN CATCH  
 DECLARE @ErrorMessage VARCHAR(MAX);  
  
  SELECT @ErrorMessage = ERROR_MESSAGE()  
  
  --INSERT Error      
  EXEC AVL_InsertError '[AVL].[TaskListUserTicketUploadFailure]', @ErrorMessage, @EmployeeID, @ProjectID   
END CATCH  
SET NOCOUNT OFF;
END
