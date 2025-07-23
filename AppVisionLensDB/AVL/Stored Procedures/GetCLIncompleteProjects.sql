    
      
CREATE procedure [AVL].[GetCLIncompleteProjects]      
AS            
BEGIN                               
 BEGIN TRY                               
  SET NOCOUNT ON;       
      
  CREATE TABLE #CLIncompleteProjects (            
 projectId INT NULL  ,      
 ContinuousLearningID INT NULL      
  )       
      
  CREATE TABLE #RulesCount (            
 projectId INT NULL  ,      
 ContinuousLearningID INT NULL,      
 ApprovedOrMuteCount bigint null      
  )       
      
  CREATE TABLE #ApproveMuteCount (            
 projectId INT NULL  ,      
 ContinuousLearningID INT NULL,      
 ApprovedOrMuteCount bigint null      
  )      
    
  Insert into #CLIncompleteProjects      
  select distinct pc.projectid,MAX(pc.ContLearningID) from ml.CL_PRJ_ContLearningState pc       
  inner join ml.CL_ProjectJobDetails pj on pj.ProjectID = pc.ProjectID group by pc.Projectid      
  union    
  select distinct pc.projectid,MAX(pc.ContLearningID) from ml.CL_PRJ_InfraContLearningState pc       
  inner join ml.CL_InfraProjectJobDetails pj on pj.ProjectID = pc.ProjectID group by pc.Projectid      
      
  Insert into #RulesCount      
  select Atrn.ProjectID,Atrn.ContinuousLearningID,count(Atrn.ID) from ml.TRN_PatternValidation Atrn      
  inner join #CLIncompleteProjects icp on icp.ProjectID = Atrn.ProjectID and icp.ContinuousLearningID = Atrn.ContinuousLearningID      
  where Atrn.IsDeleted = 0  group by Atrn.ProjectID , Atrn.ContinuousLearningID      
  union      
  select Itrn.ProjectID,Itrn.ContinuousLearningID,count(Itrn.ID) from ml.InfraTRN_PatternValidation Itrn      
  inner join #CLIncompleteProjects icp on icp.ProjectID = Itrn.ProjectID and icp.ContinuousLearningID = Itrn.ContinuousLearningID      
  where Itrn.IsDeleted = 0  group by Itrn.ProjectID , Itrn.ContinuousLearningID      
    
      
  Insert into #ApproveMuteCount      
  select Atrn.ProjectID,Atrn.ContinuousLearningID,count(Atrn.ID) from ml.TRN_PatternValidation Atrn      
  inner join #CLIncompleteProjects icp on icp.ProjectID = Atrn.ProjectID and icp.ContinuousLearningID = Atrn.ContinuousLearningID      
  where IsApprovedOrMute not in (1,2) and Atrn.IsDeleted = 0      
  group by Atrn.ProjectID , Atrn.ContinuousLearningID       
  union       
  select Itrn.ProjectID,Itrn.ContinuousLearningID,count(Itrn.ID) from ml.InfraTRN_PatternValidation Itrn      
  inner join #CLIncompleteProjects icp on icp.ProjectID = Itrn.ProjectID and icp.ContinuousLearningID = Itrn.ContinuousLearningID      
  where IsApprovedOrMute not in (1,2) and Itrn.IsDeleted = 0      
  group by Itrn.ProjectID , Itrn.ContinuousLearningID       
      
      
  select distinct rc.projectId into #CLIncompleteProject from #RulesCount rc inner join #ApproveMuteCount ac on ac.ApprovedOrMuteCount = rc.ApprovedOrMuteCount      
    
  select PLR.Associateid,PLR.Projectid,PLR.ESAProjectID,PLR.AssociateName,plr.projectname  into #DetailsFromView from RLE.VW_ProjectLevelRoleAccessDetails PLR            
 where PLR.RoleKey in ('RLE003','RLE008') and PLR.Projectid is not null;        
      
 CREATE TABLE #MLSignOffExistingProjects      
 (      
 ID INT IDENTITY(1, 1) primary key ,      
 ProjectId bigint,      
 ESAProjectID NVARCHAR(100),      
 projectname NVARCHAR(250),      
 associateId NVARCHAR(100)      
 );      
      
 --Select MLP.ID , MLP.ProjectId, STRING_AGG( Trim(plr.associateId),',' ) AS Associateid ,PLR.ESAProjectID from #tempMLNoiseIncompleteProjects MLP inner join #DetailsFromView PLR on PLR.Projectid = MLP.projectId group by MLP.ProjectId , PLR.ESAProjectID,mlp.id      
 insert into #MLSignOffExistingProjects      
 Select MLP.ProjectId,PLR.ESAProjectID,plr.projectname,plr.associateId from #CLIncompleteProject MLP inner join #DetailsFromView PLR on PLR.Projectid = MLP.projectId       
      
      
 While EXISTS(Select * From #MLSignOffExistingProjects)      
 Begin      
      
 Declare @Id int      
 Declare @EsaProjectId nvarchar(100)      
 Declare @ProjectName varchar (100)      
     
 Declare @ProjectId bigint      
 Declare @AssociateId bigint      
      
 Set @Id = (Select Top 1 Id From #MLSignOffExistingProjects)      
 select @EsaProjectId = ESAProjectID  from #MLSignOffExistingProjects where Id = @Id     
 select @ProjectName = projectname from #MLSignOffExistingProjects where Id = @Id      
 select @ProjectId = projectId from #MLSignOffExistingProjects where Id = @Id      
 select @AssociateId = associateId from #MLSignOffExistingProjects where Id = @Id      
 Declare @Description nvarchar(450)      
 set @Description = 'New Machine Learning rules has been generated as part of Continuous Learning, for the project '+@EsaProjectId+' - '+@ProjectName+'. Click here to view and approve/reject.'      
   BEGIN TRAN    
 insert into OneAVM.MA.MyActivity (ActivityDescription,SourceRecordID,ActivityTo,ApprovedBy,DueDate,    
           IsExpired,IsViewed,WorkItemID,RequestorJson,ActivityInfo,Comments,ApprovalStatus,Navigation,    
           IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,IsMailSent,MailContent,MailTo)       
  values (@Description,@ProjectId,@AssociateId,NULL,DATEADD(day,7,getdate()),0,0,101,NULL,NULL,NULL,NULL,'https://applensqa.cognizant.com/LearningWeb/#/nav',    
  0,'MIGRATED',GETDATE(),NULL,NULL,NULL,NULL,NULL)      
  COMMIT    
    Delete #MLSignOffExistingProjects Where Id = @ID      
      
 End      
       
 drop table #CLIncompleteProject    
 drop table #RulesCount      
 drop table #ApproveMuteCount      
 drop table #CLIncompleteProjects      
 drop table #DetailsFromView      
 drop table #MLSignOffExistingProjects      
    
  SET NOCOUNT OFF        
 END TRY                              
    BEGIN CATCH                               
        DECLARE @ErrorMessage VARCHAR(MAX);                               
        SELECT @ErrorMessage = ERROR_MESSAGE()       
  ROLLBACK    
        --INSERT Error                                   
           EXEC AVL_INSERTERROR  '[AVL].[GetCLIncompleteProjects]', @ErrorMessage,  0, 0                
    END CATCH                               
  END
