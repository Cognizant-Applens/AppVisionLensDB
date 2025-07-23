CREATE  PROCEDURE [AVL].[UpdateMachineLearningActivityStatus] --'146918',4,1              
@ProjectID bigint,               
@Stage smallint,              
@isApp int              
AS                    
BEGIN                                       
 BEGIN TRY                                       
  SET NOCOUNT ON;              
DECLARE @Result BIT;               
Declare @SupportTypeId INT              
DECLARE @ContLearningID BIGINT              
Select @SupportTypeId=SupportTypeId from avl.Map_ProjectConfig where projectId=@ProjectId              
DECLARE @Count INT              
 IF (@SupportTypeId=1 or @SupportTypeId=2)              
 Begin              
 Set @Result= 1;         
 IF(@Stage = 4)              
   BEGIN           
    select distinct Associateid,ESAProjectID,projectname from RLE.VW_ProjectLevelRoleAccessDetails               
       where RoleKey in ('RLE003','RLE008') and Projectid=@ProjectId   and isDeleted=0            
   END        
 end              
 else              
 Begin              
   IF (@Stage = 1)                
   BEGIN                
    IF (@isApp=1)              
    BEGIN              
    SELECT @Count=Count(*) FROM ML.InfraConfigurationProgress              
    WHERE id  = ( SELECT MAX(id) FROM ML.InfraConfigurationProgress where projectid=@ProjectId)               
    AND (IsNoiseEliminationSentorReceived='Saved') AND isdeleted=0              
    IF(@Count=1) BEGIN Set @Result= 0;END              
    ELSE BEGIN Set @Result= 1;END              
   END              
   ELSE              
   BEGIN              
    SELECT @Count=Count(*) FROM ML.ConfigurationProgress              
    WHERE id  = ( SELECT MAX(id) FROM ML.ConfigurationProgress where projectId=@ProjectId)               
    AND (IsNoiseEliminationSentorReceived='Saved') AND isdeleted=0              
    IF(@Count=1) BEGIN Set @Result= 0; END              
    ELSE BEGIN Set @Result= 1; END              
   END              
                 
  END                
  IF (@Stage = 2)                
   BEGIN                
    IF (@isApp=1)              
    BEGIN              
    SELECT @Count=Count(*) FROM ML.InfraConfigurationProgress              
     WHERE id  = ( SELECT MAX(id) FROM ML.InfraConfigurationProgress where projectid=@ProjectId)               
     and IsSamplingSentOrReceived='Received' and ISNULL(IsMLSentOrReceived,'')='' AND isdeleted=0              
    IF(@Count=1) BEGIN Set @Result=  0;END              
    ELSE BEGIN Set @Result=  1;END              
   END              
   ELSE              
   BEGIN              
    SELECT @Count=Count(*) FROM ML.ConfigurationProgress              
     WHERE id  = ( SELECT MAX(id) FROM ML.ConfigurationProgress where projectid=@ProjectId)               
     and IsSamplingSentOrReceived='Received' and  ISNULL(IsMLSentOrReceived,'')='' AND isdeleted=0              
    IF(@Count=1) BEGIN Set @Result=  0; END              
    ELSE BEGIN Set @Result=  1; END              
   END              
                 
  END                
  IF (@Stage = 3)                
   BEGIN                
    IF (@isApp=1)              
    BEGIN              
    SELECT @Count=Count(*) FROM ML.InfraConfigurationProgress icp inner join avl.MAS_ProjectDebtDetails pd on icp.projectid=pd.projectid              
     WHERE id  = ( SELECT MAX(id) FROM ML.InfraConfigurationProgress where projectid=@ProjectId)               
     and IsMLSentOrReceived='Received' and ISNULL(MLSignOffDateInfra,'')='' AND icp.isdeleted=0 AND pd.isdeleted=0              
    IF(@Count=1) BEGIN Set @Result=  0;END              
    ELSE BEGIN Set @Result=  1;END              
   END              
   ELSE              
   BEGIN              
    SELECT @Count=Count(*) FROM ML.ConfigurationProgress icp inner join avl.MAS_ProjectDebtDetails pd on icp.projectid=pd.projectid              
     WHERE id  = ( SELECT MAX(id) FROM ML.ConfigurationProgress where projectid=@ProjectId)               
     and IsMLSentOrReceived='Received' and ISNULL(MLSignOffDate,'')='' AND icp.isdeleted=0 AND pd.isdeleted=0              
    IF(@Count=1) BEGIN Set @Result=  0; END              
    ELSE BEGIN Set @Result=  1; END              
   END              
          
  END                
  IF(@Stage = 4)              
   BEGIN              
    IF (@isApp=1)              
      BEGIN              
      set @ContLearningID  = ( SELECT MAX(ContLearningID) FROM  ml.CL_PRJ_InfraContLearningState  where projectid=@ProjectId and isDeleted=0 )               
      SELECT @Count=Count(*) FROM  ml.InfraTRN_PatternValidation               
      where ContinuousLearningID=@ContLearningID and ProjectId=@ProjectId and isApprovedOrMute in (1,2) and isDeleted=0              
      IF(@Count=0) BEGIN Set @Result=  1;              
      select distinct Associateid,ESAProjectID,projectname from RLE.VW_ProjectLevelRoleAccessDetails               
       where RoleKey in ('RLE003','RLE008') and Projectid=@ProjectId   and isDeleted=0            
      END              
      ELSE BEGIN Set @Result= 0;END              
     END              
    ELSE              
     BEGIN              
      set @ContLearningID  = ( SELECT MAX(ContLearningID) FROM  ml.CL_PRJ_ContLearningState where projectid=@ProjectId and isDeleted=0)             
      SELECT @Count=Count(*) FROM  ml.TRN_PatternValidation               
      where ContinuousLearningID=@ContLearningID and ProjectId=@ProjectId and isApprovedOrMute in (1,2) and isDeleted=0              
      IF(@Count=0) BEGIN Set @Result=  1;              
      select distinct Associateid,ESAProjectID,projectname from RLE.VW_ProjectLevelRoleAccessDetails               
       where RoleKey in ('RLE003','RLE008') and Projectid=@ProjectId  and isDeleted=0            
      END              
      ELSE BEGIN Set @Result=  0;END              
     END              
                  
   END              
                 
                
                 
 END              
 SELECT @Result AS Result              
   END TRY                                      
   BEGIN CATCH                                       
    DECLARE @ErrorMessage VARCHAR(MAX);                                       
    SELECT @ErrorMessage = ERROR_MESSAGE()                                       
    --INSERT Error                                           
    EXEC AVL_INSERTERROR  '[AVL].[UpdateMachineLearningActivityStatus]', @ErrorMessage,  0, 0                                       
   END CATCH                                       
 END
