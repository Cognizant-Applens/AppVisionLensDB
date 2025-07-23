   

CREATE PROCEDURE [PP].[GetWorkitemDetailsForOpportunityCalculation](
@EsaAccountID VARCHAR(MAX)
)
AS
BEGIN
BEGIN TRY
SET NOCOUNT ON;


   SELECT DISTINCT PM.ProjectID,PM.EsaProjectID As EsaProjId,PM.ProjectName,
                C.ESA_AccountID AS EsaAcc,AM.Application_Id As ApplicationId,
                WIT.WorkTypeMapId,WT.ProjectWorkTypeName,
				WIT.Actual_StartDate AS ActualStartDate,WIT.Actual_EndDate As ActualEndDate,
                WIT.Assignee,WIT.WorkItem_Id AS WorkItemId,WIT.WorkItem_Title AS WorkItemTitle, WIT.ServiceId,
				SAM.ServiceName,SAM.ActivityName,WD.Hours TimeEffort,SM.[TimesheetStatus] AS TimesheetStatus
	FROM AVL.MAS_ProjectMaster(NOLOCK) PM
   INNER JOIN AVL.Customer(NOLOCK) C ON C.CustomerID=PM.CustomerID AND C.IsDeleted=0
   INNER JOIN [ADM].[ALM_TRN_WorkItem_Details] (NOLOCK)  WIT ON WIT.Project_Id =PM.ProjectID
   inner join PP.ALM_MAP_WorkType (NOLOCK)  WT on WIT.WorkTypeMapId=WT.WorkTypeMapId AND WT.IsDeleted=0
   inner join [ADM].[ALM_TRN_WorkItem_ApplicationMapping] (NOLOCK)  AM on AM.WorkItemDetailsId=WIT.WorkItemDetailsId  AND AM.IsDeleted=0
    INNER JOIN [ADM].[TM_TRN_WorkItemTimesheetDetail] (NOLOCK) WD on WD.WorkItemDetailsId=WIT.WorkItemDetailsId AND WD.IsDeleted=0
   INNER JOIN AVL.TK_MAS_ServiceActivityMapping (NOLOCK) SAM ON SAM.ServiceID = WIT.ServiceID and WD.ActivityID = SAM.ActivityID  AND SAM.IsDeleted=0   INNER JOIN [AVL].[TM_PRJ_Timesheet] (NOLOCK)  TS ON TS.TimesheetId=WD.TimesheetId 
   INNER JOIN [AVL].[MAS_TimesheetStatus] (NOLOCK)  SM ON TS.StatusId=SM.[TimesheetStatusId] AND SM.IsDeleted=0
   WHERE SAM.ServiceId in (11,17,68) AND WIT.IsDeleted=0 AND PM.IsDeleted=0
   AND WT.WorkTypeId NOT IN (4) AND C.ESA_AccountID=@EsaAccountID

   SET NOCOUNT OFF
END TRY  
BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		EXEC AVL_InsertError '[PP].[GetWorkitemDetailsForOpportunityCalculation]',@ErrorMessage,0,0
		
	END CATCH  
END
