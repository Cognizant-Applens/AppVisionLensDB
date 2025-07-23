/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

-- =============================================
-- Author:		Sreeya
-- Create date: 1-8-2019
-- Description:	Creates the data for sampling,pattern generation in initial and continuous learning.
-- =============================================
--exec AVL.MyTask_InitialLearning_ContinuousLearning 9086,'383323',1
CREATE PROCEDURE [AVL].[MyTask_InitialLearning_ContinuousLearning] 
@ProjectID bigint,
@UserID varchar(100),
@Option int
AS
BEGIN
BEGIN TRY
		

DECLARE @taskstatus varchar(100),@tasktype as varchar(100) ;

declare @prjESAID varchar(max),@prjName varchar(max),@msg varchar(max),@CustomerID bigint;

declare @tasknameInitialSampling varchar(500),@taskurlInitialSampling varchar(max),@taskapplicationInitialSampling varchar(500); 
declare @taskidInitialSampling int=7;
select @tasknameInitialSampling=taskname from dbo.taskmaster where taskid=@taskidInitialSampling;
select @taskurlInitialSampling=taskurl from dbo.taskurl where taskid=@taskidInitialSampling;
select @taskapplicationInitialSampling=applicationname from dbo.taskapplication where taskid=@taskidInitialSampling;


declare @tasknameInitialPattern varchar(500),@taskurlInitialPattern varchar(max),@taskapplicationInitialPattern varchar(500); 
declare @taskidInitialPattern int=8;
select @tasknameInitialPattern=taskname from dbo.taskmaster where taskid=@taskidInitialPattern;
select @taskurlInitialPattern=taskurl from dbo.taskurl where taskid=@taskidInitialPattern;
select @taskapplicationInitialPattern=applicationname from dbo.taskapplication where taskid=@taskidInitialPattern;



declare @tasknameCont varchar(500),@taskurlCont varchar(max),@taskapplicationCont varchar(500); 
declare @taskidCont int=10;
select @tasknameCont=taskname from dbo.taskmaster where taskid=@taskidCont;
select @taskurlCont=taskurl from dbo.taskurl where taskid=@taskidCont;
select @taskapplicationCont=applicationname from dbo.taskapplication where taskid=@taskidCont;


select @taskstatus=status from dbo.taskstatus where taskstatusid=1;
select @tasktype=tasktype from dbo.tasktype where tasktypeid=1;

SELECT @prjESAID=EsaProjectID,@prjName=ProjectName,@CustomerID=CustomerID FROM AVL.MAS_ProjectMaster 
WHERE ProjectID=@ProjectID AND IsDeleted=0 ;
--select * from avl.MAS_LoginMaster where EmployeeID=383323
PRINT @prjESAID
PRINT @prjName
SELECT DISTINCT TSApproverID,EmployeeID INTO #tblLeadsMain FROM AVL.MAS_LoginMaster WHERE ProjectID=@ProjectID AND IsDeleted=0 ; 
SELECT DISTINCT M.TSApproverID INTO #tblLeads FROM #tblLeadsMain M JOIN #tblLeadsMain T ON 
 M.TsApproverID=T.EmployeeID AND M.TSApproverID IS NOT NULL


IF @Option =1
BEGIN
PRINT 1
SET @msg='Sampling tickets has been generated in Initial Learning for the Project : '+@prjESAID +' - '+ @prjName;
PRINT @msg

PRINT @CustomerID
select TSApproverID as'UserID',@taskidInitialSampling as 'TaskID',@tasknameInitialSampling as 'taskName',@taskurlInitialSampling as 'TaskURL',@msg
as 'taskdetails',@taskapplicationInitialSampling as 'Application',@taskstatus as 'Status',
getdate() as 'refreshedtime','system' as 'createdby', getdate() as 'createdtime',null as 'modifiedby',null as 'modifiedtime',
@tasktype as 'tasktype',NULL as 'expirydate','N' as 'read', NULL as 'duedate','2' as 'expiryafterread',
@ProjectID as 'AccountID' 
 from #tblLeads ;
END

IF @Option =2
BEGIN
PRINT 2
SET @msg='Initial Learning Patterns are generated for the Project : '+@prjESAID +' - '+ @prjName;
select TSApproverID as'UserID',@taskidInitialPattern as 'TaskID',@tasknameInitialPattern as 'taskName',@taskurlInitialPattern as 'TaskURL',@msg
as 'taskdetails',@taskapplicationInitialPattern as 'Application',@taskstatus as 'Status',
getdate() as 'refreshedtime','system' as 'createdby', getdate() as 'createdtime',null as 'modifiedby',null as 'modifiedtime',
@tasktype as 'tasktype',NULL as 'expirydate','N' as 'read', NULL as 'duedate','2' as 'expiryafterread',
@ProjectID as 'AccountID' 
 from #tblLeads ;
END

IF @Option =3
BEGIN
PRINT 3
SET @msg='Continuous Learning Patterns are generated for the Project : '+@prjESAID +' - '+ @prjName;
select TSApproverID as'UserID',@taskidCont as 'TaskID',@tasknameCont as 'taskName',@taskurlCont as 'TaskURL',@msg
as 'taskdetails',@taskapplicationCont as 'Application',@taskstatus as 'Status',
getdate() as 'refreshedtime','system' as 'createdby', getdate() as 'createdtime',null as 'modifiedby',null as 'modifiedtime',
@tasktype as 'tasktype',NULL as 'expirydate','N' as 'read', NULL as 'duedate','2' as 'expiryafterread',
@ProjectID as 'AccountID' 
 from #tblLeads ;
END
	

END TRY
BEGIN CATCH

	DECLARE @ErrorMessage VARCHAR(MAX);

	SELECT @ErrorMessage = ERROR_MESSAGE()

	--INSERT Error

	EXEC AVL_InsertError 'AVL.MyTask_InitialLearning_ContinuousLearning',@ErrorMessage,0,0
			
END CATCH
END
