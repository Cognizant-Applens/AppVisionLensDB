CREATE PROCEDURE [AVL].[GetHealingTicketsEndDate]    
@UserID varchar(50)    
AS    
    
BEGIN 
SET NOCOUNT ON;
BEGIN TRY    
    
--drop table #HealingTickets    
--delete FROM AVL.TaskPlannedEndDate_HealingTicketsID    
SELECT RP.ProjectId,HT.HealingTicketID,RP.PlannedEndDate,HT.DartStatusID,HT.ReleasePlanning INTO #HealingTickets    
FROM avl.DEBT_PRJ_HealProjectPatternMappingDynamic DY (NOLOCK) JOIN avl.DEBT_TRN_HealTicketDetails HT (NOLOCK)    
ON DY.ProjectPatternMapID=HT.ProjectPatternMapID AND ISNULL(DY.ManualNonDebt,0) != 1 AND ISNULL(HT.ManualNonDebt,0) != 1    
JOIN avl.DEBT_MAS_ReleasePlanDetails RP (NOLOCK)     
ON RP.Id=HT.ReleasePlanning     
WHERE  RP.IsDeleted=0 AND HT.IsDeleted=0 AND (HT.DARTStatusID NOT IN (5,7,8,9,13) OR HT.DARTStatusID IS NULL)    
AND CAST(GETDATE() AS DATE) > CAST(RP.PlannedEndDate AS DATE)  AND HT.ReleasePlanning IS NOT NULL    
AND DY.IsDeleted=0 AND DY.PatternStatus=1 AND HT.TicketType<>'K';    
--AND HT.HealingTicketID NOT IN     
--(SELECT DISTINCT HealingTicketID FROM AVL.TaskPlannedEndDate_HealingTicketsID)    
    
--INSERT INTO [AVL].[TaskPlannedEndDate_HealingTicketsID] (ProjectID,HealingTicketID)     
--SELECT DISTINCT ProjectID,HealingTicketID FROM #HealingTickets    
    
declare @taskidPlanned int=16;    
declare @tasknamePlanned varchar(500),@taskurlPlanned varchar(max),@taskapplicationPlanned varchar(500),@taskstatus varchar(100),@tasktype as varchar(100) ;    
select @tasknamePlanned=taskname from dbo.taskmaster (NOLOCK) where taskid=@taskidPlanned;    
select @taskurlPlanned=taskurl from dbo.taskurl (NOLOCK) where taskid=@taskidPlanned;    
select @taskapplicationPlanned=applicationname from dbo.taskapplication (NOLOCK) where taskid=@taskidPlanned;    
select @taskstatus=status from dbo.taskstatus (NOLOCK) where taskstatusid=2;    
select @tasktype=tasktype from dbo.tasktype (NOLOCK) where tasktypeid=2;    
    
IF EXISTS (SELECT 1 FROM #HealingTickets (NOLOCK))    
BEGIN    
    
--SELECT DISTINCT HealingTicketID FROM #HealingTickets;    
WITH CTEAHOp AS(    
    
SELECT DISTINCT AccessLevelID  AS 'ProjectID',EmployeeID,PM.EsaProjectID,PM.ProjectName FROM AVL.UserRoleMapping UR (NOLOCK)    
JOIN AVL.MAS_ProjectMaster PM (NOLOCK) ON PM.ProjectID=UR.AccessLevelID WHERE RoleID=3 AND AccessLevelSourceID=4 AND IsActive=1 AND PM.IsDeleted=0    
AND NOT EXISTS(SELECT DISTINCT URM.EmployeeID FROM AVL.UserRoleMapping URM (NOLOCK) WHERE     
URM.RoleID<>3 AND URM.IsActive=1 AND URM.EmployeeID=UR.EmployeeID AND URM.AccessLevelID=PM.ProjectID)    
    
),    
CTEAHPlanALL AS    
(    
    
SELECT C.EmployeeID,C.EsaProjectID,C.ProjectName,A.ProjectID,A.healingTicketID,    
A.PlannedEndDate,A.DartStatusID,A.ReleasePlanning FROM CTEAHOp C JOIN #HealingTickets A (NOLOCK) ON A.projectID=C.ProjectID    
)    
SELECT AH7.EmployeeID as'UserID',@taskidPlanned as 'TaskID',@tasknamePlanned as 'TaskName',@taskurlPlanned as 'URL',    
'The Automation/Healing ticket '+ AH7.HealingTicketID +' crossed planned end date '+convert(varchar(1000),CAST(AH7.PlannedEndDate AS DATE),101)+'  for the Project : '+AH7.EsaProjectID +'-'+ AH7.ProjectName    
as 'TaskDetails',@taskapplicationPlanned as 'Application',@taskstatus as 'Status',    
getdate() as 'RefreshedTime','system' as 'CreatedBy', getdate() as 'CreatedTime',null as 'ModifiedBy',null as 'ModifiedTime',    
@tasktype as 'TaskType',null as 'ExpiryDate','N' as 'Read',CAST(AH7.PlannedEndDate AS DATE) as 'DueDate',0 as 'ExpiryAfterRead',    
ProjectID as 'AccountID'    
FROM CTEAHPlanALL AH7    
    
    
END    
END TRY    
BEGIN CATCH    
    
 DECLARE @ErrorMessage VARCHAR(MAX);    
    
 SELECT @ErrorMessage = ERROR_MESSAGE()    
    
 --INSERT Error    
    
 EXEC AVL_InsertError 'AVL.GetHealingTicketsEndDate',@ErrorMessage,0,0    
       
END CATCH
SET NOCOUNT OFF;
END
