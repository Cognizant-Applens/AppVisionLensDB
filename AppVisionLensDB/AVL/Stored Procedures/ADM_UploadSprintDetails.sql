  

  
CREATE   PROCEDURE [AVL].[ADM_UploadSprintDetails]     
(@TVPSprintDetails as [ADM_TVP_SprintDetails] readonly,    
    
@UserId NVarchar(50),    
@ProjectId BIGINT,    
@FileName NVarchar(100) = null,    
@UploadMode int,    
@UploadedStartTime DateTime,    
@UploadedFileName NVarchar(200))    
    
AS    
BEGIN    
      BEGIN TRY    
      
 DECLARE @SprintDetails Table(    
 [SprintName] [nvarchar](1000) NULL,    
 [SprintDescription][nvarchar](4000) null,    
 [StartDate][datetime] NULL,    
 [EndDate] [datetime] NULL,    
 [Owner] [nvarchar](50) NULL,    
 [Status] [nvarchar](20) NULL,    
 [StatusMapId] int,    
 [PodId] int null,    
 [ReleaseDetailsId] BIGINT null )    
    
 DECLARE @rowCount int;    
    
 SET @rowCount=0;  
 INSERT INTO @SprintDetails  
 SELECT SprintName,SprintDescription,CONVERT(DATETIME, DATEADD(HOUR, -5, DATEADD(MINUTE, -30, StartDate))),CONVERT(DATETIME, DATEADD(HOUR, -5, DATEADD(MINUTE, -30, EndDate))),Owner,status,StatusMapId,PodId,ReleaseDetailsId from @TVPSprintDetails t   
  LEFT JOIN PP.ALM_MAS_Status s on t.Status = s.StatusName   
   LEFT JOIN PP.ALM_MAP_Status MP on MP.StatusId = s.StatusId  
     AND MP.ProjectId  IS NULL   
     AND IsDefault = 'Y' --@ProjectId  
    
 --select * from @SprintDetails    
  MERGE INTO  ADM.ALM_TRN_Sprint_Details AS target    
       USING (SELECT  SprintName,SprintDescription,[Owner],StartDate,    
           EndDate,StatusMapId,PodId,ReleaseDetailsId    
      FROM   @SprintDetails SP)    
     
   AS source    
               ON source.SprintName = target.SprintName and target.Projectid = @ProjectId    
          
   WHEN MATCHED then    
   Update    
   set sprintName = source.SprintName,    
   SprintDesc = source.SprintDescription,    
       
   SprintOwner= case when target.SprintOwner is not null then target.SprintOwner else source.Owner end,    
   --StatusId=source.StatusMapId ,    
     
   SprintStartDate = source.StartDate,    
      SprintEndDate =source.EndDate,    
   ModifiedBy = @UserId,    
   ModifiedDate = getdate(),    
   ADMSourceId = 2 ,    
   PodId = source.PodId,    
   ReleaseDetailsId = source.ReleaseDetailsId    
    
         WHEN NOT MATCHED BY target THEN     
        Insert(sprintName,SprintDesc,SprintOwner,StatusId,SprintStartDate,    
          SprintEndDate,ProjectId,IsDeleted,CreatedBy,CreatedDate,ADMSourceId,PodId,ReleaseDetailsId)    
    Values     
     ( source.SprintName,source.SprintDescription,    
      source.Owner,source.StatusMapId,source.StartDate,source.EndDate,@ProjectId,0,@UserId,GetDate(),2,PodId,source.ReleaseDetailsId) ;    
       
    SELECT @rowCount =@@ROWCOUNT;              
     
 IF (@FileName != '' OR @FileName != null)    
  BEGIN    
    INSERT INTO ADM.ALM_TRN_WorkItemUploadStatus    
    (UploadedFileName,ProjectID,UploadMode,TemplateType,TotalWorkItems,UploadedStartTime,UploadedEndTime,status,ErrorFileName,CreatedBy,CreatedDate)    
    Values(@UploadedFileName,@ProjectId,@UploadMode,'Sprint',@rowCount,@UploadedStartTime,getDate(),'Failure',@FileName,@UserId,GETDATE());    
  END    
 ELSE IF( @FileName = '' OR @FileName is null )    
     BEGIN    
    INSERT INTO ADM.ALM_TRN_WorkItemUploadStatus    
    (UploadedFileName,ProjectID,UploadMode,TemplateType,TotalWorkItems,UploadedStartTime,UploadedEndTime,status,ErrorFileName,CreatedBy,CreatedDate)    
    Values(@UploadedFileName,@ProjectId,@UploadMode,'Sprint',@rowCount,@UploadedStartTime,getdate(),'Success',@FileName,@UserId,GETDATE());    
  END    
 END try    
    
      BEGIN catch    
          DECLARE @ErrorMessage VARCHAR(2000);    
          SELECT @ErrorMessage = Error_message()    
     EXEC AVL_InsertError '[AVL].[ADM_UploadSprintDetails]', @ErrorMessage,@UserId,@ProjectID    
      END catch    
  END 
