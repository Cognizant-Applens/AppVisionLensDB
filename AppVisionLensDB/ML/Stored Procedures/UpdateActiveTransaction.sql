                        
CREATE PROCEDURE [ML].[UpdateActiveTransaction]                                                    
 @TransactionId bigint,                                                  
 @UserId nvarchar(50),                                              
 @SupportTypeId int                                              
AS                                                    
BEGIN                                                    
  SET NOCOUNT ON;                                                  
 BEGIN TRY             
 BEGIN TRAN          
 Declare @Dist INT;                                             
 Declare @ProjectId bigint = (select distinct projectid from ML.TRN_MLTransaction(NOLOCK) where TransactionId = @TransactionId)                                                
                                              
  UPDATE ML.TRN_MLTransaction SET                                                   
  IsActiveTransaction = 0,                                                  
  ModifiedBy = @UserId,                                                  
  ModifiedDate = GETDATE()                                                  
  WHERE ProjectId = @ProjectId AND SupportTypeId=@SupportTypeId AND IsActiveTransaction = 1 AND IsDeleted = 0                                                  
                                                    
  UPDATE ML.TRN_MLTransaction SET                                                   
  IsActiveTransaction = 1,                                                  
  ModifiedBy = @UserId,                                                  
  ModifiedDate = GETDATE()                                                  
  WHERE TransactionId = @TransactionId and ProjectId = @ProjectId AND IsDeleted = 0                                                
                                                
                                       
                                  
  if(@SupportTypeId=1)                                                
begin                                  
                            
 select @Dist=count(*)from ml.trn_mltransaction where projectid=@ProjectId and SupportTypeId=1 and IsDeleted=0                                                
                                                
 IF((@Dist>1) AND                                               
 (Select top 1 SignOffDate from ml.trn_mltransaction                                               
 where projectId=@projectId and SupportTypeId=1 and IsDeleted=0 and SignOffDate is not null) is not null)                                                                                    
   BEGIN                                                
    select 1  , @projectId                                              
   END                                                
  ELSE                                                
   BEGIN                                                
    select 3                                                
   END                                           
                                     
                                  
end                                                
else                                               
begin                             
                          
 select @Dist=count(*)from ml.trn_mltransaction where projectid=@ProjectId and SupportTypeId=2  AND IsDeleted = 0                                                  
                                                
 IF((@Dist>1) AND (Select top 1 SignOffDate from ml.trn_mltransaction                                                 
   where projectId=@projectId and SupportTypeId=2 and isDeleted=0 and SignOffDate is not null) is not null)                                                                                    
   BEGIN                                                
    select 2   , @projectId                                              
   END                                                
  ELSE                                    
   BEGIN                                                
    select 3                                
   END                                     
                                     
             
end                                               
                                  
                               
 DECLARE @NextDayID INT = 5;                                  
 DECLARE @MLSignOffDate datetime = (SELECT Signoffdate from ML.TRN_MLTRANSACTION WHERE TransactionId = @TransactionId)                                  
 DECLARE @JobDate datetime = DATEADD(DAY, (DATEDIFF(DAY, @NextDayID, @MLSignOffDate) / 7) * 7 + 7, @NextDayID)  

 IF(SELECT COUNT(*) FROM [ML].[ClusteringCLProjects](NOLOCK) WHERE ProjectId = @ProjectId AND SupportTypeId = @SupportTypeId) > 0                                  
 BEGIN                                   
  UPDATE  [ML].[ClusteringCLProjects] SET TransactionID = @TransactionId,     
  JobStatusKey = 'SK006' , IsDeleted = 0,RegeneratedDate = null,IsRegenerate = 0, --//Regenerate Fix     
  JobRunDate = @JobDate, IsManual =0,                        
  ModifiedBy = @UserId ,  ModifiedDate = GETDATE() where  ProjectId = @ProjectId AND SupportTypeId = @SupportTypeId;                                  
 END                                  
 ELSE                                  
 BEGIN                                   
  INSERT  [ML].[ClusteringCLProjects] (ProjectId,TransactionId,JobRunDate,SupportTypeId,JobStatusKey,IsDeleted,CreatedBy,CreatedDate,IsManual)                       
  VALUES (@ProjectId,@TransactionId,@JobDate,@SupportTypeId,'SK006',0,@UserId,GETDATE(),0)     
  --  INSERT  [ML].[ClusteringCLProjects] (ProjectId,TransactionId,JobRunDate,SupportTypeId,IsDeleted,CreatedBy,CreatedDate,IsManual)                       
  --VALUES (@ProjectId,@TransactionId,@JobDate,@SupportTypeId,0,@UserId,GETDATE(),0)     
 END           
 COMMIT TRAN          
 END TRY                         
 BEGIN CATCH            
   ROLLBACK TRAN          
    DECLARE @ErrorMessage VARCHAR(MAX);                                                  
 SELECT @ErrorMessage = ERROR_MESSAGE()                                                  
                                                  
 EXEC AVL_InsertError '[ML].[UpdateActiveTransaction]', @ErrorMessage, 0,0                                                  
 END CATCH;                                                    
                                                    
 SET NOCOUNT OFF;                                                  
END 