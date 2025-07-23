
CREATE   PROCEDURE [AVL].[ADM_UploadWorkItemDetails]   
(  
@UserId NVarchar(50),  
@ProjectId BIGINT,  
@FileName NVarchar(100) = null,  
@UploadMode int,  
@UploadedStartTime DateTime,  
@UploadedFileName NVarchar(100),  
@TVPWorkItemDetails as AVL.ADM_TVP_WorkItemDetails readonly)  
  
AS  
BEGIN  
BEGIN TRY   
 --SET NOCOUNT ON;  
     
   DECLARE @rowCount int;  
   DECLARE @IdTable TABLE  (insertedid BIGINT,WorkItemID [nvarchar](100));  
 CREATE TABLE #ImportWorkItemDetails(  
 [WorkItemType] bigint NOT NULL,  
 [WorkItemID] [nvarchar](100) NOT NULL,  
 [WorkItemTitle] [nvarchar](max) NOT NULL,  
 [Description] [nvarchar](max) NULL,  
 [Status] bigint NOT NULL,  
 [Activity] [nvarchar](250) NULL,  
 [Application] bigint NOT NULL,  
 [CreatedDate] [datetime] NOT NULL,  
 [CreatedBy] [nvarchar](50) NULL,  
 [Assignee] [nvarchar](50) NULL,  
 [ServiceId] bigint NULL,  
 [PriorityMapId] bigint NULL,  
 [SeverityMapId] bigint NULL,  
 [Risk] [nvarchar](250) NULL,  
 [Story] int NULL,  
 [ActualStartDate] [datetime] NULL,  
 [ActualEndDate] [datetime] NULL,  
 [PlannedStartDate] [datetime] NULL,  
 [PlannedEndDate] [datetime] NULL,  
 [EstimationPoints] [nvarchar](100) NULL,  
 [PlannedEstimate] [decimal](18, 2) NULL,  
 [AcutalEffort] [decimal](18, 2) NULL,  
 [SprintDetails] bigint NULL,  
 [TargetDate] [datetime] NULL,  
 [ModifiedDate] [datetime] NULL,  
 [ModifiedBy] [nvarchar](50) NULL,  
 [LinkedParentID] [nvarchar](100) NULL,  
 [LinkedChildID] [nvarchar](10) NULL,  
 [Theme] bigint NULL,  
 [IsMilestonemet] bit NULL,  
 [BugPhaseTypeMapId] smallint NULL)  
     
   
	Insert into #ImportWorkItemDetails (WorkItemType,WorkItemID,WorkItemTitle,Description,Status,Activity,Application,
	CreatedDate,CreatedBy,Assignee,ServiceId,PriorityMapId,SeverityMapId,Risk,Story,ActualStartDate,ActualEndDate,
	PlannedStartDate,PlannedEndDate,EstimationPoints,PlannedEstimate,AcutalEffort,SprintDetails,TargetDate,
	ModifiedDate,[ModifiedBy],LinkedParentId,LinkedChildId,Theme,IsMilestonemet,BugPhaseTypeMapId)
	
	select WorkItemType,WorkItemID,WorkItemTitle,Description,Status,Activity,Application,
	CONVERT(DATETIME, DATEADD(HOUR, -5, DATEADD(MINUTE, -30, CreatedDate))),CreatedBy,Assignee,ServiceId,PriorityMapId,SeverityMapId,Risk,Story,
	CONVERT(DATETIME, DATEADD(HOUR, -5, DATEADD(MINUTE, -30, ActualStartDate))),CONVERT(DATETIME, DATEADD(HOUR, -5, DATEADD(MINUTE, -30, ActualEndDate))),
	CONVERT(DATETIME, DATEADD(HOUR, -5, DATEADD(MINUTE, -30, PlannedStartDate))),CONVERT(DATETIME, DATEADD(HOUR, -5, DATEADD(MINUTE, -30, PlannedEndDate))),
	EstimationPoints,PlannedEstimate,AcutalEffort,SprintDetails,TargetDate,
	CONVERT(DATETIME, DATEADD(HOUR, -5, DATEADD(MINUTE, -30, ModifiedDate))),[ModifiedBy],LinkedParentId,LinkedChildId,Theme,IsMilestonemet,BugPhaseTypeMapId from @TVPWorkItemDetails
  
  
  MERGE INTO  [ADM].[ALM_TRN_WorkItem_Details] AS t  
          using (SELECT WorkItemType,WorkItemID,WorkItemTitle,Description,Status,Activity,  
 CreatedDate,isnull(CreatedBy,@UserId) CreatedBy ,Assignee,ServiceId,PriorityMapId,SeverityMapId,Risk,Story,ActualStartDate,ActualEndDate,  
 PlannedStartDate,PlannedEndDate,EstimationPoints,PlannedEstimate,AcutalEffort,SprintDetails,TargetDate,  
 ModifiedDate,ModifiedBy,LinkedParentId,LinkedChildId,Theme,IsMilestonemet,BugPhaseTypeMapId  FROM   #ImportWorkItemDetails) AS source  
               ON source.WorkItemID = t.WorkItem_Id   and t.Project_Id= @ProjectId      
  
   WHEN matched THEN  
   UPDATE SET t.WorkTypeMapId=source.WorkItemType,t.WorkItem_Id=Source.WorkItemID,  
   t.WorkItem_Title=Source.WorkItemTitle,t.StatusMapId=Source.Status,t.CreatedDate=Source.CreatedDate,  
   --Below are Non Mandatory fields  
   --t.WorkItem_Description=Source.Description,  
   t.WorkItem_Description = case when Source.Description is not null and Source.Description <> '' and Source.Description <> t.WorkItem_Description then Source.Description else t.WorkItem_Description end,  
   --t.Tool_Activity=Source.Activity,  
   t.Tool_Activity = case when Source.Activity is not null then Source.Activity else t.Tool_Activity end,  
   --t.Assignee=Source.Assignee,  
   t.Assignee = case when Source.Assignee is not null then Source.Assignee else t.Assignee end,  
   --t.ServiceId=Source.ServiceId,  
   t.ServiceId = case when Source.ServiceId is not null then Source.ServiceId else t.ServiceId end,  
   --t.priorityMapId=Source.PriorityMapId,  
   t.priorityMapId = case when Source.priorityMapId is not null then Source.priorityMapId else t.priorityMapId end,  
   --t.SeverityMapId=Source.SeverityMapId,  
   t.SeverityMapId = case when Source.SeverityMapId is not null then Source.SeverityMapId else t.SeverityMapId end,  
   --t.Risk=Source.Risk,  
   t.Risk = case when Source.Risk is not null and Source.Risk <> t.Risk then Source.Risk else t.Risk end,  
   --t.[Order]=Source.Story,  
   t.[Order] = case when Source.Story is not null and Source.Story <> t.[Order] then Source.Story else t.[Order] end,  
   --t.Actual_StartDate=Source.ActualStartDate,  
   t.Actual_StartDate = case when Source.ActualStartDate is not null then Source.ActualStartDate else t.Actual_StartDate end,  
   --t.Actual_EndDate=Source.ActualEndDate,  
   t.Actual_EndDate = case when Source.ActualEndDate is not null then Source.ActualEndDate else t.Actual_EndDate end,  
   --t.Planned_StartDate=Source.PlannedStartDate,  
   t.Planned_StartDate = case when Source.PlannedStartDate is not null then Source.PlannedStartDate else t.Planned_StartDate end,  
   --t.Planned_EndDate=Source.PlannedEndDate,  
   t.Planned_EndDate = case when Source.PlannedEndDate is not null then Source.PlannedEndDate else t.Planned_EndDate end,  
   --t.Estimation_Points=Source.EstimationPoints,  
   t.Estimation_Points = case when Source.EstimationPoints is not null then Source.EstimationPoints else t.Estimation_Points end,  
   --t.Planned_Estimate=Source.PlannedEstimate,  
   t.Planned_Estimate = case when Source.PlannedEstimate is not null then Source.PlannedEstimate else t.Planned_Estimate end,  
   --t.Actual_Effort=Source.AcutalEffort,  
   t.Actual_Effort = case when Source.AcutalEffort is not null then Source.AcutalEffort else t.Actual_Effort end,  
   --t.SprintDetailsId=Source.SprintDetails,  
   t.SprintDetailsId = case when Source.SprintDetails is not null then Source.SprintDetails else t.SprintDetailsId end,  
   --t.Target_Date=Source.TargetDate,  
   t.Target_Date = case when Source.TargetDate is not null then Source.TargetDate else t.Target_Date end,  
   --t.ThemeMapId=Source.Theme,  
   t.ThemeMapId = case when Source.Theme is not null then Source.Theme else t.ThemeMapId end,  
   --t.Linked_ParentId=Source.LinkedParentId,  
   t.Linked_ParentId = case when Source.LinkedParentId is not null then Source.LinkedParentId else t.Linked_ParentId end,  
   t.IsDeleted=0,  
   --t.CreatedBy=isnull(Source.CreatedBy,@UserId),  
   t.CreatedBy = case when isnull(Source.CreatedBy,@UserId) <> t.CreatedBy then isnull(Source.CreatedBy,@UserId) else t.CreatedBy end,  
   --t.ModifiedBy=Source.ModifiedBy,  
   t.ModifiedBy = case when Source.ModifiedBy is not null and Source.ModifiedBy <> '' and Source.ModifiedBy <> t.ModifiedBy then Source.ModifiedBy else @UserId end,
   t.ModifiedDate=isnull(Source.ModifiedDate,getdate()),  
   --t.ModifiedDate = case when isnull(Source.ModifiedDate,getdate()) <> t.ModifiedDate then isnull(Source.ModifiedDate,getdate()) else t.ModifiedDate end,  
   --t.IsMilestonemet=Source.IsMilestonemet,  
   --t.BugPhaseTypeMapId=Source.BugPhaseTypeMapId,  
   t.BugPhaseTypeMapId = case when Source.BugPhaseTypeMapId is not null then Source.BugPhaseTypeMapId else t.BugPhaseTypeMapId end  
         WHEN NOT MATCHED BY target THEN  
            INSERT  VALUES (Source.WorkItemType,@ProjectId,Source.WorkItemID,Source.WorkItemTitle,Source.Description,  
   Source.Status,Source.Activity,Source.Assignee,Source.ServiceId,Source.PriorityMapId,Source.SeverityMapId,Source.Risk,  
   Source.Story,Source.ActualStartDate,Source.ActualEndDate,Source.PlannedStartDate,Source.PlannedEndDate,  
   Source.EstimationPoints,Source.PlannedEstimate,Source.AcutalEffort,Source.SprintDetails,  
   Source.TargetDate,null,2,Source.Theme,Source.LinkedParentId,null,0,isnull(Source.CreatedBy,@UserId)  
   ,Source.CreatedDate,Source.ModifiedBy,Source.ModifiedDate,NULL,NULL,Source.IsMilestonemet,NULL,Source.BugPhaseTypeMapId)  
  
     
    output   inserted.WorkItemDetailsId,inserted.WorkItem_Id INTO @IdTable;   
           
   SELECT @rowCount =@@ROWCOUNT;  
   print @rowCount  
   IF (@rowCount>0)  
   BEGIN  
    MERGE INTO [ADM].[ALM_TRN_WorkItem_ApplicationMapping] AS t1  
          USING (Select temp.insertedid as WorkItemDetailId,s.Application,s.CreatedBy,s.CreatedDate  
        from #ImportWorkItemDetails s inner join @IdTable temp on temp.WorkItemID = s.WorkItemID) AS Source  
               ON Source.WorkItemDetailId = t1.WorkItemDetailsId   
  
   WHEN matched THEN  
    UPDATE SET t1.Application_Id=Source.Application,  
    t1.isdeleted=0,  
    ModifiedBy=@userId,  
    modifiedDate=getdate()  
             
         WHEN NOT MATCHED BY TARGET THEN  
    INSERT VALUES(Source.WorkItemDetailId,Source.Application,0,isnull(Source.CreatedBy,@userid),Source.createddate,null,null);  
  
   END  
      
  IF @FileName != '' OR @FileName != null  
  BEGIN  
    INSERT INTO ADM.ALM_TRN_WorkItemUploadStatus  
    (UploadedFileName,ProjectID,UploadMode,TemplateType,TotalWorkItems,UploadedStartTime,UploadedEndTime,status,ErrorFileName,CreatedBy,CreatedDate)  
    Values(@UploadedFileName,@ProjectId,@UploadMode,'WorkItem',@rowCount,@UploadedStartTime,getDate(),'Failure',@FileName,@UserId,GETDATE());  
  END  
 ELSE IF( (@FileName = '' OR @FileName is null ) And @rowCount>0)  
     BEGIN  
    INSERT INTO ADM.ALM_TRN_WorkItemUploadStatus  
    (UploadedFileName,ProjectID,UploadMode,TemplateType,TotalWorkItems,UploadedStartTime,UploadedEndTime,status,ErrorFileName,CreatedBy,CreatedDate)  
    Values(@UploadedFileName,@ProjectId,@UploadMode,'WorkItem',@rowCount,@UploadedStartTime,getdate(),'Success',@FileName,@UserId,GETDATE());  
  END  
  END TRY  
  BEGIN CATCH  
  DECLARE @ErrorMessage VARCHAR(4000);  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
  --INSERT Error      
  EXEC AVL_InsertError '[AVL].[ADM_UploadWorkItemDetails] ', @ErrorMessage,@UserId,@ProjectID  
  RETURN @ErrorMessage  
  END CATCH   
  
END 
