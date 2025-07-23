-- =============================================
-- Author:		Saravanan.B
-- Create date: 07-08-2019
-- Description:	Gets the tasks for DebEngine CancellationTicket Count.
-- =============================================
CREATE PROCEDURE [AVL].[WorkEffort_MyTaskGetCancellationTickets]
AS
BEGIN
BEGIN TRY

DECLARE @TaskName VARCHAR(500),@TaskUrl VARCHAR(max),@TaskApplication VARCHAR(500),@TaskStatus VARCHAR(100),@TaskType AS VARCHAR(100) ;
DECLARE @TaskId INT=27;
SELECT @TaskName=taskname FROM dbo.taskmaster WHERE taskid=@TaskId;
SELECT @TaskUrl=taskurl FROM dbo.taskurl WHERE taskid=@TaskId AND IsDeleted=0;
SELECT @TaskApplication=applicationname FROM dbo.taskapplication WHERE taskid=@TaskId AND IsDeleted=0;
SELECT @TaskStatus=status FROM dbo.taskstatus WHERE taskstatusid=1 AND IsDeleted=0;
SELECT @TaskType=tasktype FROM dbo.tasktype WHERE tasktypeid=1 AND IsDeleted=0;

---SDD User---
SELECT DISTINCT CP.Project_ID AS 'EsaProjectID',DY.ProjectID,PM.ProjectName,PM.CustomerID,CP.DeliveryManagerID  AS 'EmployeeID',
 COUNT(HT.ReasonForCancellation) AS 'CancellationTicketCount'
 INTO #TempCancelledTicketCountSD FROM avl.DEBT_TRN_HealTicketDetails HT WITH (NOLOCK)
JOIN avl.DEBT_PRJ_HealProjectPatternMappingDynamic DY WITH (NOLOCK) on HT.ProjectPatternMapID=DY.ProjectPatternMapID
JOIN AVL.MAS_ProjectMaster PM WITH (NOLOCK) ON PM.ProjectID=DY.ProjectID AND PM.IsDeleted=0
JOIN CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_Project CP WITH (NOLOCK) ON PM.EsaProjectID=CP.Project_ID  
WHERE HT.IsDeleted=0 and DY.IsDeleted=0 AND HT.DARTStatusID =5
AND HT.CancellationDate BETWEEN  cast(dateadd(day, -7, HT.CancellationDate) as DATETIME) AND GETDATE()  
AND ISNULL(HT.ManualNonDebt,0)<>1 AND ISNULL(DY.ManualNonDebt,0)<>1
GROUP BY CP.Project_ID,DY.ProjectID,PM.ProjectName,CP.DeliveryManagerID,PM.CustomerID

---SDM User---
SELECT DISTINCT CP.Project_ID AS 'EsaProjectID',DY.ProjectID,PM.ProjectName,PM.CustomerID,CP.Project_Owner AS 'EmployeeID',
 COUNT(HT.ReasonForCancellation) AS 'CancellationTicketCount'
 INTO #TempCancelledTicketCountSM FROM avl.DEBT_TRN_HealTicketDetails HT WITH (NOLOCK)
JOIN avl.DEBT_PRJ_HealProjectPatternMappingDynamic DY WITH (NOLOCK) on HT.ProjectPatternMapID=DY.ProjectPatternMapID
JOIN AVL.MAS_ProjectMaster PM WITH (NOLOCK) ON PM.ProjectID=DY.ProjectID AND PM.IsDeleted=0
JOIN CTSINTBMVPCRSR1.CentralRepository_Report.dbo.vw_CentralRepository_Project CP WITH (NOLOCK) ON PM.EsaProjectID=CP.Project_ID  
WHERE HT.IsDeleted=0 and DY.IsDeleted=0 AND HT.DARTStatusID =5
AND HT.CancellationDate BETWEEN cast(dateadd(day, -7, HT.CancellationDate) as DATETIME) AND GETDATE() 
AND ISNULL(HT.ManualNonDebt,0)<>1 AND ISNULL(DY.ManualNonDebt,0)<>1
GROUP BY CP.Project_ID,DY.ProjectID,PM.ProjectName,CP.Project_Owner,PM.CustomerID




SELECT  EmployeeID AS'UserId'
       ,@TaskId AS 'TaskId'
	   ,@TaskName AS 'TaskName'
	   ,@TaskUrl AS 'TaskUrl'
       ,'('+CAST(CancellationTicketCount AS VARCHAR(10))+')' + ' Automation/Healing Tickets are cancelled by the Associates for the project "'+ RTRIM(EsaProjectID) + ': ' + ProjectName 
	     +'". Validate the reason for cancellation and do the necessary configuration change to avoid A/H ticket creation for invalid scenarios'
         AS 'TaskDetails'
       ,@TaskApplication AS 'Application'
       ,@TaskStatus AS 'Status'
       ,GETDATE() AS 'RefreshedTime'
       ,'system' AS 'CreatedBy'
       , GETDATE() AS 'CreatedTime'
       ,NULL AS 'ModifiedBy'
       ,NULL AS 'ModifiedTime'
       ,@TaskType AS 'TaskType'
       ,NULL AS 'ExpiryDate'
       ,NULL AS 'DueDate' --- Due Date
       ,'N' AS 'Read'
       ,2 AS 'ExpiryAfterRead'
       ,CustomerID AS 'Accountid'
   FROM
	    #TempCancelledTicketCountSD
UNION 

SELECT  EmployeeID AS'UserId'
       ,@TaskId AS 'TaskId'
	   ,@TaskName AS 'TaskName'
	   ,@TaskUrl AS 'TaskUrl'
       ,'('+ CAST(CancellationTicketCount AS VARCHAR(10))+')' + ' Automation/Healing Tickets are cancelled by the Associates for the project "'+ RTRIM(EsaProjectID) + ': ' + ProjectName 
	     +'". Validate the reason for cancellation and do the necessary configuration change to avoid A/H ticket creation for invalid scenarios'
         AS 'TaskDetails'
       ,@TaskApplication AS 'Application'
       ,@TaskStatus AS 'Status'
       ,GETDATE() AS 'RefreshedTime'
       ,'system' AS 'CreatedBy'
       , GETDATE() AS 'CreatedTime'
       ,NULL AS 'ModifiedBy'
       ,NULL AS 'ModifiedTime'
       ,@TaskType AS 'TaskType'
       ,NULL AS 'ExpiryDate'
       ,NULL AS 'DueDate' --- Due Date
       ,'N' AS 'Read'
       ,2 AS 'ExpiryAfterRead'
       ,CustomerID AS 'Accountid'
   FROM
	    #TempCancelledTicketCountSM
   DROP TABLE #TempCancelledTicketCountSD
   DROP TABLE  #TempCancelledTicketCountSM

END TRY

  BEGIN CATCH
  
  	DECLARE @ErrorMessage VARCHAR(MAX);
  	SELECT @ErrorMessage = ERROR_MESSAGE()
  
  	--INSERT Error
  	EXEC AVL_InsertError '[AVL].[WorkEffort_MyTaskGetCancellationTickets]',@ErrorMessage,0,0
  			
  END CATCH
END