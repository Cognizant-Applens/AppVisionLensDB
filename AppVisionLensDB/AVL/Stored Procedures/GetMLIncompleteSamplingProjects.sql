      
CREATE procedure [AVL].[GetMLIncompleteSamplingProjects]      
AS            
BEGIN                               
 BEGIN TRY                               
  SET NOCOUNT ON;       
      
   CREATE TABLE #tempMLSamplingIncompleteProjects (            
 projectId INT NULL  ,      
 ID INT NULL      
 )       
 Insert into #tempMLSamplingIncompleteProjects            
 Select cp.projectId,cp.ID from ml.configurationprogress cp           
 inner join avl.MAS_ProjectDebtDetails MP on MP.projectId = cp.projectID         
 where cp.IsSamplingSentOrReceived = 'Received' and ISNULL(cp.IsMLSentOrReceived,'') = '' and cp.IsDeleted = 0 and mp.IsDeleted = 0      
 UNION       
 Select cp.projectId,cp.ID from ml.InfraConfigurationProgress cp          
 inner join avl.MAS_ProjectDebtDetails MP on MP.projectId = cp.projectID        
 where cp.IsSamplingSentOrReceived = 'Received' and ISNULL(cp.IsMLSentOrReceived,'') = '' and cp.IsDeleted = 0 and mp.IsDeleted = 0      
      
 select * , ROW_NUMBER() OVER(Partition by ProjectId ORDER BY ProjectId) AS RowIndex into #MLSamplingIncompleteProjects from #tempMLSamplingIncompleteProjects      
      
 delete #tempMLSamplingIncompleteProjects      
      
 Insert into #tempMLSamplingIncompleteProjects       
  select ProjectId,Id from #MLSamplingIncompleteProjects where RowIndex = 1      
      
 select PLR.Associateid,PLR.Projectid,PLR.ESAProjectID,PLR.AssociateName,plr.projectname  into #DetailsFromView from RLE.VW_ProjectLevelRoleAccessDetails PLR            
 where PLR.RoleKey in ('RLE003','RLE008') and PLR.Projectid is not null;        
      
 CREATE TABLE #MLSignOffExistingProjects      
 (      
 ID INT IDENTITY(1, 1) primary key ,      
 InitialLearningId bigint,      
 ProjectId bigint,      
 ESAProjectID NVARCHAR(100),      
 projectname NVARCHAR(250),      
 associateId NVARCHAR(100)      
 );      
      
 --Select MLP.ID , MLP.ProjectId, STRING_AGG( Trim(plr.associateId),',' ) AS Associateid ,PLR.ESAProjectID from #tempMLNoiseIncompleteProjects MLP inner join #DetailsFromView PLR on PLR.Projectid = MLP.projectId group by MLP.ProjectId , PLR.ESAProjectID  ,mlp.id      
 insert into #MLSignOffExistingProjects      
 Select MLP.ID as InitialLearningId,MLP.ProjectId,PLR.ESAProjectID,plr.projectname,plr.associateId from #tempMLSamplingIncompleteProjects MLP inner join #DetailsFromView PLR on PLR.Projectid = MLP.projectId       
      
 While EXISTS(Select * From #MLSignOffExistingProjects)      
 Begin      
      
 Declare @Id int      
 Declare @EsaProjectId NVARCHAR(100)      
 Declare @ProjectName varchar (100)      
 Declare @Description varchar(250)      
 Declare @ProjectID bigint      
 Declare @AssociateId bigint      
      
    Select Top 1 @Id = Id From #MLSignOffExistingProjects      
 select @EsaProjectId = ESAProjectID  from #MLSignOffExistingProjects where Id = @Id      
 select @ProjectName = projectname from #MLSignOffExistingProjects where Id = @Id      
 select @ProjectID = ProjectID from #MLSignOffExistingProjects where Id = @Id      
 select @AssociateId = associateId from #MLSignOffExistingProjects where Id = @Id      
 set @Description = 'Sampling tickets has been identified for the project '+@EsaProjectId+' - '+@ProjectName+'.Click here to capture Debt information for the tickets.'      
   BEGIN TRAN    
   insert into OneAVM.MA.MyActivity (ActivityDescription,SourceRecordID,ActivityTo,ApprovedBy,DueDate,    
           IsExpired,IsViewed,WorkItemID,RequestorJson,ActivityInfo,Comments,ApprovalStatus,Navigation,    
           IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,IsMailSent,MailContent,MailTo)       
  values (@Description,@ProjectId,@AssociateId,NULL,DATEADD(day,7,getdate()),0,0,19,NULL,NULL,NULL,NULL,'https://applensqa.cognizant.com/LearningWeb/#/nav',    
  0,'MIGRATED',GETDATE(),NULL,NULL,NULL,NULL,NULL)      
  COMMIT    
    Delete #MLSignOffExistingProjects Where Id = @ID      
      
 End      
 drop table #MLSamplingIncompleteProjects      
 drop table #tempMLSamplingIncompleteProjects      
  SET NOCOUNT OFF        
 END TRY                              
    BEGIN CATCH                               
        DECLARE @ErrorMessage VARCHAR(MAX);                          
        SELECT @ErrorMessage = ERROR_MESSAGE()       
  ROLLBACK    
        --INSERT Error                                   
        EXEC AVL_INSERTERROR  '[AVL].[GetMLIncompleteSamplingProjects]', @ErrorMessage,  0, 0                               
    END CATCH                               
  END
