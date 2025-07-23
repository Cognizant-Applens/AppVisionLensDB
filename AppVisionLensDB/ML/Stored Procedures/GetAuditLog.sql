CREATE PROCEDURE [ML].[GetAuditLog]   --739              
@TransactionId BIGINT                                        
AS                            
                          
BEGIN                                                                   
BEGIN TRY                            
                       
DECLARE @Auditlogid BIGINT;                    
SET @Auditlogid = (SELECT TOP(1)AuditLogId from  [ML].[TRN_AuditLog] WHERE MLTransactionId=@TransactionId AND LearningTypeKey ='LT003' order by CreatedDate desc)                     
                   
IF @Auditlogid IS NOT NULL AND @Auditlogid != 0                      
BEGIN                    
DECLARE @ClusterTotal BIGINT = 0;         
DECLARE @ResolutionTotal BIGINT = 0;      
DECLARE @SupportTypeId int;      
      
SET @SupportTypeId = (SELECT SupportTypeId FROM ML.TRN_MLTransaction WHERE TransactionId=@TransactionId)       
      
IF @SupportTypeId = 1        
BEGIN        
SET @ClusterTotal = (select count(ClusterID_Desc)  as Total                            
from [ML].[TRN_ClusteringTicketValidation_App] where MLTransactionId = @TransactionId AND ClusterID_Desc!= 0                           
)         
        
set @ResolutionTotal = (select count(ClusterID_Resolution) as Total                            
from [ML].[TRN_ClusteringTicketValidation_App] where MLTransactionId = @TransactionId AND ClusterID_Resolution !=0)           
        
END        
ELSE        
BEGIN        
SET @ClusterTotal = (select count(ClusterID_Desc)  as Total                            
from [ML].[TRN_ClusteringTicketValidation_Infra] where MLTransactionId = @TransactionId AND ClusterID_Desc!= 0                           
)          
        
set @ResolutionTotal = (select count(ClusterID_Resolution) as Total                            
from [ML].[TRN_ClusteringTicketValidation_Infra] where MLTransactionId = @TransactionId AND ClusterID_Resolution !=0)           
END        
                      
UPDATE [ML].[TRN_AuditLog]  SET Total = @ClusterTotal +@ResolutionTotal  Where AuditLogId = @Auditlogid                    
END             
        
select * into #tempauditlog from(SELECT AL.AuditLogId,LT.LearningTypeName,TR.SignOffDate,AL.SignOffBy as SignOffId,         
Cast('' as nvarchar(200)) as SignOffBy,        
CASE WHEN ISNULL(AL.ModifiedDate,'') != '' THEN AL.ModifiedDate ELSE AL.CreatedDate END AS ModifiedDate,        
CASE WHEN ISNULL(AL.ModifiedBy,'') != '' THEN AL.ModifiedBy ELSE AL.CreatedBY END AS ModifiedId,        
Cast('' as nvarchar(200)) as ModifiedBy,        
Total,ModelVersion,Comments                             
FROM [ML].[TRN_AuditLog] AL                          
INNER JOIN [MAS].[ML_LearningType] LT ON LT.LearningTypeKey=AL.LearningTypeKey         
INNER JOIN [ML].[TRN_MLTransaction] TR ON TR.TransactionId = AL.MLTransactionId and TR.IsDeleted = 0           
WHERE MLTransactionId=@TransactionId and AL.IsDeleted=0) as Teamp        
                            
    update A set a.ModifiedBy=LM.EmployeeName from   #tempauditlog A        
    inner join [AVL].[MAS_LoginMaster] LM on A.ModifiedId = LM.EmployeeID        
        
    update A set a.SignOffBy=LM.EmployeeName from   #tempauditlog A        
    inner join [AVL].[MAS_LoginMaster] LM on A.SignOffId = LM.EmployeeID   
   
  update #tempauditlog set ModifiedBy = 'System'    Where  isnull(ModifiedBy,'') =''  
        
 select AuditlogId,LearningTypeName,SignOffDate,SignOffBy,ModifiedDate,ModifiedBy,Total,ModelVersion,Comments  from  #tempauditlog  order by Modelversion desc      
                            
END TRY                                                                  
BEGIN CATCH                                                                 
                                                                               
  DECLARE @ErrorMessage VARCHAR(MAX);                                                                
  SELECT @ErrorMessage = ERROR_MESSAGE()                                                               
                                 
  EXEC AVL_InsertError '[ML].[GetAuditLog]', @ErrorMessage, 0,0                                                                
         
 END CATCH                                                                   
END
