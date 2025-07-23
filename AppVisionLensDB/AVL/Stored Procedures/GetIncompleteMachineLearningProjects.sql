      
CREATE  PROCEDURE [AVL].[GetIncompleteMachineLearningProjects]             
AS            
BEGIN                               
 BEGIN TRY                               
  SET NOCOUNT ON;             
  CREATE TABLE #MLSignOffProjects (            
  projectId INT NULL          
  )          
        
  Insert into #MLSignOffProjects      
  select distinct mpd.ProjectId from avl.MAS_ProjectDebtDetails mpd      
  inner join avl.MAP_ProjectConfig mp on mp.ProjectID = mpd.ProjectID      
  inner join avl.MAS_ProjectMaster pm on pm.ProjectID = mp.ProjectID      
  where pm.IsDebtEnabled = 'Y' and ((mp.SupportTypeId = 1 and mpd.IsAutoClassified = 'Y' and ISNULL(mpd.MLSignOffDate,'') = '')       
  or (mp.SupportTypeId = 2 and mpd.IsAutoClassifiedInfra = 'Y' and ISNULL(mpd.MLSignOffDateInfra,'') = '')       
  or (mp.SupportTypeId = 3 and (mpd.IsAutoClassified = 'Y' or  mpd.IsAutoClassifiedInfra = 'Y') and (ISNULL(mpd.MLSignOffDate,'') = '' or ISNULL(mpd.MLSignOffDateInfra,'') = '')))      
  and mpd.Isdeleted = 0 and pm.isdeleted = 0      
           
           
 select PLR.Associateid,PLR.Projectid,PLR.ESAProjectID,PLR.AssociateName,plr.projectname  into #DetailsFromView from RLE.VW_ProjectLevelRoleAccessDetails PLR            
 where PLR.RoleKey in ('RLE003','RLE008') and PLR.Projectid is not null;          
          
 --Select MLP.ProjectId, STRING_AGG( Trim(plr.associateId),',' ) AS Associateid ,PLR.ESAProjectID from #MLSignOffProjects MLP inner join #tempTable PLR on PLR.Projectid = MLP.projectId group by MLP.ProjectId , PLR.ESAProjectID        
 CREATE TABLE #MLSignOffExistingProjects      
 (      
 ID INT IDENTITY(1, 1) primary key ,      
 ProjectId bigint,      
 ESAProjectID NVARCHAR(100),      
 projectname NVARCHAR(250),      
 associateId NVARCHAR(100)      
 );      
 insert into #MLSignOffExistingProjects      
 Select MLP.ProjectId,PLR.ESAProjectID,plr.projectname,plr.associateId from #MLSignOffProjects MLP inner join #DetailsFromView PLR on PLR.Projectid = MLP.projectId       
      
 --select * from #MLSignOffExistingProjects      
      
 While EXISTS(Select * From #MLSignOffExistingProjects)      
 Begin      
      
 Declare @Id int      
 Declare @EsaProjectId NVARCHAR(100)      
 Declare @ProjectName varchar (100)      
 Declare @ProjectId bigint       
 Declare @AssociateId bigint      
 Declare @Description varchar(250)      
      
    Select Top 1 @Id = Id From #MLSignOffExistingProjects      
 select @EsaProjectId = ESAProjectID  from #MLSignOffExistingProjects where Id = @Id      
 select @ProjectName = projectname from #MLSignOffExistingProjects where Id = @Id      
 select @ProjectId = projectId from #MLSignOffExistingProjects where Id = @Id      
 select @AssociateId = associateId from #MLSignOffExistingProjects where Id = @Id      
 set @Description = 'Initial Learning has not been signed off for the project '+@EsaProjectId+'-'+@ProjectName+'. Click here to generate Machine Learning Rules and Sign Off'      
    
     
   BEGin TRAN    
 insert into OneAVM.MA.MyActivity (ActivityDescription,SourceRecordID,ActivityTo,ApprovedBy,DueDate,    
           IsExpired,IsViewed,WorkItemID,RequestorJson,ActivityInfo,Comments,ApprovalStatus,Navigation,    
           IsDeleted,CreatedBy,CreatedDate,ModifiedBy,ModifiedDate,IsMailSent,MailContent,MailTo)       
  values (@Description,@ProjectId,@AssociateId,NULL,DATEADD(day,365,getdate()),0,0,17,NULL,NULL,NULL,NULL,'https://applensqa.cognizant.com/LearningWeb/#/nav',    
  0,'MIGRATED',GETDATE(),NULL,NULL,NULL,NULL,NULL)      
  COMMIT    
    Delete #MLSignOffExistingProjects Where Id = @ID      
      
 END      
 DROP TABLE #MLSignOffProjects            
 DROP TABLE #DetailsFromView          
 SET NOCOUNT OFF        
 END TRY                              
    BEGIN CATCH                               
        DECLARE @ErrorMessage VARCHAR(MAX);                               
        SELECT @ErrorMessage = ERROR_MESSAGE()     
  ROLLBACK    
        --INSERT Error                                   
        EXEC AVL_INSERTERROR  '[AVL].[GetIncompleteMachineLearningProjects]', @ErrorMessage,  0, 0                               
    END CATCH                               
 END
