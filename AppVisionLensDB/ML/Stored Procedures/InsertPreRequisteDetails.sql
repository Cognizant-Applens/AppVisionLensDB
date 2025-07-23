CREATE PROCEDURE [ML].[InsertPreRequisteDetails]                                                          
                   -- Add the parameters for the stored procedure here                                                            
    @PreRequisiteJsonData Nvarchar(max)                                         
AS                                                            
BEGIN                                         
BEGIN TRY              
BEGIN TRAN            
       -- SET NOCOUNT ON added to prevent extra result sets from                                                            
       -- interfering with SELECT statements. select * from [ML].[TRN_MLTransaction]                                                            
SET NOCOUNT ON;                                            
DECLARE @Createdby Nvarchar(50)                                        
DECLARE @InitialMLID BIGINT = 0;                                                            
DECLARE @Categorical NVarchar(max)                                                           
DECLARE @AlgorithmKey Nvarchar(50) = 'AL002';                                         
                                        
SELECT * INTO #tmpPreRequisiteData from(                                        
SELECT TransactionId, ProjectId, IssueDefinitionId, ResolutionProvidedId,Categorical,FromDate, ToDate, IsNoiseEnabled, IsInfraSelected, CreatedBy                                        
 FROM OPENJSON(@PreRequisiteJsonData)                                        
  WITH (                                        
   TransactionId INT '$.TransactionId',                                        
   ProjectId bigint '$.ProjectId',                                        
   IssueDefinitionId int '$.IssueDefinitionId',                                        
   ResolutionProvidedId int '$.ResolutionProvidedId',                                        
   Categorical Nvarchar(max) '$.Categorical',                                        
   FromDate datetime '$.FromDate',                                        
   ToDate Datetime '$.ToDate',                                        
   IsNoiseEnabled bit '$.IsNoiseEnabled',                                        
   IsInfraSelected bit '$.IsInfraSelected',                                        
   CreatedBy Nvarchar(50) '$.CreatedBy'                                        
    )T                                        
        )A                                        
                                   
Declare @ProjectID bigint;                    
SET @InitialMLID = (select TransactionId from #tmpPreRequisiteData)                                        
SET @CreatedBy = (select CreatedBy from #tmpPreRequisiteData)                               
SET @Categorical = (select Categorical from #tmpPreRequisiteData)               
SET @ProjectID = (select ProjectId from #tmpPreRequisiteData)           
          
DECLARE @SupportTypeId INT=(select           
CASE WHEN IsInfraSelected = 0 THEN          
1          
ELSE          
2          
END          
 from #tmpPreRequisiteData)           
                                        
IF(@InitialMLID = 0 OR @InitialMLID = NULL)                                        
BEGIN                  
              
IF EXISTS(Select * from ML.TRN_MLTransaction              
 where AlgorithmKey='AL002' and SignOffDate is null  and ProjectID=@ProjectID AND SupportTypeId=@SupportTypeId and isDeleted=0)              
 BEGIN              
 Select Top 1 TransactionId from ML.TRN_MLTransaction               
 where AlgorithmKey='AL002' and SignOffDate is null  and ProjectID=@ProjectID   AND SupportTypeId=@SupportTypeId and isDeleted=0           
 Order by TransactionId Desc           
  COMMIT TRAN          
  RETURN              
 END                   
              
 INSERT INTO [ML].[TRN_MLTransaction](ProjectId,AlgorithmKey,IsActiveTransaction,IssueDefinitionId,ResolutionProviderId,FromDate,ToDate,                                        
 IsNoiseEnabled,SupportTypeId, ScreenId, IsDeleted, CreatedBy,CreatedDate)                                          
 SELECT ProjectId, @AlgorithmKey, 0, IssueDefinitionId, ResolutionProvidedId,FromDate, ToDate, IsNoiseEnabled,                                        
 CASE WHEN IsInfraSelected = 0 THEN 1 ELSE 2 END,2, 0, CreatedBy, GETDATE()                                        
 FROM #tmpPreRequisiteData                
                  
 SET @InitialMLID = SCOPE_IDENTITY();     
 --Audit Log start---  
DECLARE @AuditSupportTypeId int;                  
Declare @AuditprojectId BIGINT;                 
DECLARE @PRFromDate datetime;                    
DECLARE @PRToDate datetime;                    
DECLARE @ModelVersion BIGINT = 0;                  
DECLARE @Total BIGINT;           
DECLARE @ClusterTotal BIGINT = 0;            
DECLARE @ResolutionTotal BIGINT = 0;    
DECLARE @AuditCreatedby Nvarchar(50);  
                    
SET @AuditSupportTypeId = (SELECT SupportTypeId FROM ML.TRN_MLTransaction WHERE TransactionId=@InitialMLID)                           
SET @PRFromDate=(SELECT FromDate FROM  ML.TRN_MLTransaction WHERE TransactionId=@InitialMLID)                    
SET @PRToDate=(SELECT ToDate FROM  ML.TRN_MLTransaction WHERE TransactionId=@InitialMLID)                    
SET @AuditprojectId=(Select ProjectId from ml.trn_mltransaction where TransactionId=@InitialMLID)    
SET @AuditCreatedby =(Select CreatedBy from ml.trn_mltransaction where TransactionId=@InitialMLID)        
        
  
INSERT INTO [ML].[TRN_AuditLog](MLTransactionId, SignOffDate, Total, ModelVersion, PRFromDate, PRToDate, IsDeleted, CreatedBy,CreatedDate, LearningTypeKey, SignOffBy)                   
VALUES(@InitialMLID,GETDATE(),@ClusterTotal,@ModelVersion + 1,@PRFromDate,@PRToDate,0,@AuditCreatedby,GETDATE(),'LT002',@AuditCreatedby)  
  
 --Audit Log END---  
  
  
  
  
  
  
END                                        
ELSE                               
BEGIN           
        
 IF(SElect Count(Signoffdate) from ML.TRN_MLTransaction  WHERE TransactionId = @InitialMLID AND IsDeleted = 0 AND Signoffdate IS NOT NULL) > 0            
 BEGIN            
 UPDATE ML.ClusteringCLProjects SET                                    
  JobStatusKey = NULL                 
  WHERE TransactionId = @InitialMLID AND IsDeleted = 0              
 END          
        
UPDATE A SET A.IssueDefinitionId = B.IssueDefinitionId, A.ResolutionProviderId = B.ResolutionProvidedId,                                                      
      A.FromDate = B.FromDate, A.IsNoiseEnabled = B.IsNoiseEnabled, A.ToDate = B.ToDate,                   
  -- A.SupportTypeId = CASE WHEN B.IsInfraSelected = 0 THEN 1 ELSE 2 END ,               
   A.ModifiedBy = B.CreatedBy, A.ModifiedDate = GetDate(),                      
   --A.Jobstatuskey = null --, A.ModelAccuracy = NULL          
   A.JobStatusKey = CASE WHEN A.Signoffdate IS NULL THEN NULL ELSE A.JobStatusKey END         
FROM [ML].[TRN_MLTransaction] A                                         
INNER JOIN #tmpPreRequisiteData B ON A.TransactionId = B.TransactionId           
        
                                        
END                                        
                                        
DELETE FROM [ML].[TRN_TransactionCategorical] WHERE MLTransactionId =@InitialMLID                                                    
IF (ISNULL(@Categorical, '') <> '')                                                            
BEGIN                                                            
     CREATE TABLE #TransactionCategorical (CategoricalFieldId   INT Not NULL )                                                            
     INSERT INTO #TransactionCategorical  SELECT * FROM Split(@Categorical, ',')                                          
                                          
                                      
                                        
     INSERT INTO [ML].[TRN_TransactionCategorical](MLTransactionId,CategoricalFieldId,IsDeleted      
      ,CreatedBy,CreatedDate) (select @InitialMLID,CategoricalFieldId,0                                                            
      ,@CreatedBy,Getdate() from #TransactionCategorical)                                          
                                        
 DROP Table #TransactionCategorical                                        
END                                                            
                                                        
select @InitialMLID                                  
                                         
DROP Table #tmpPreRequisiteData             
COMMIT TRAN                                  
END TRY                                        
                                        
BEGIN CATCH              
 ROLLBACK TRAN            
 DECLARE @ErrorMessage VARCHAR(MAX);                                        
                                        
 SELECT                                        
 @ErrorMessage = ERROR_MESSAGE()            
                                        
 --INSERT Error                                        
 EXEC AVL_INSERTERROR '[ML].[InsertPreRequisteDetails]'                                        
 ,@ErrorMessage                                        
 ,0                                        
 ,0                                        
END CATCH                  
          
END
