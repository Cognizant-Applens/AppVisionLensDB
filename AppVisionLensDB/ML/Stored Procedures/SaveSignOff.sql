CREATE PROCEDURE [ML].[SaveSignOff]                                                          
@TransactionId BIGINT,                                                
@UserId nvarchar(50)                                      
AS                                                              
BEGIN                                                                     
BEGIN TRY                       
BEGIN TRAN                  
DECLARE @SupportTypeId int;                            
Declare @projectId BIGINT;                           
DECLARE @PRFromDate datetime;                              
DECLARE @PRToDate datetime;                              
DECLARE @ModelVersion BIGINT = 0;                            
DECLARE @Total BIGINT;                     
DECLARE @ClusterTotal BIGINT = 0;                      
DECLARE @ResolutionTotal BIGINT = 0;                    
                              
SET @SupportTypeId = (SELECT SupportTypeId FROM ML.TRN_MLTransaction WHERE TransactionId=@TransactionId)                                     
SET @PRFromDate=(SELECT FromDate FROM  ML.TRN_MLTransaction WHERE TransactionId=@TransactionId)                              
SET @PRToDate=(SELECT ToDate FROM  ML.TRN_MLTransaction WHERE TransactionId=@TransactionId)                              
SET @projectId=(Select ProjectId from ml.trn_mltransaction where TransactionId=@TransactionId)                            
                              
UPDATE ML.TRN_MLTransaction SET SignOffDate=GetDate(),ScreenId=1 WHERE TransactionId=@TransactionId     
       
EXEC [ML].[UpdateActiveTransaction] @TransactionId,@UserId,@SupportTypeId                                      
                          
------------------------------AuditLog Insert part-------------------------                          
                          
SET @ModelVersion =  ISNULL ((Select ModelVersion from [ML].[TRN_AuditLog] where MLTransactionId=@TransactionId),0)                     
                    
IF @SupportTypeId = 1                  
BEGIN       
    
    
--UPDATE IsOverWrite Flag    
    
UPDATE TV SET TV.IsOverwrite=1  , TV.ModifiedBy = @UserId , TV.ModifiedDate= GetDate()  
FROM [ML].[TRN_ClusteringTicketValidation_App](NOLOCK) TV     
JOIN [ML].[TRN_ClusteringOutcomeUploadedData_App](NOLOCK) UD ON     
UD.MLTransactionId = TV.MLTransactionId AND UD.TicketID = TV.TicketID    
WHERE TV.MLTransactionId = @TransactionId     
AND ((CASE WHEN ISNULL(TV.DebtClassificationID,0)=0 THEN UD.DebtClassificationID   
ELSE TV.DebtClassificationID END) <> UD.DebtClassificationID   
OR (CASE WHEN ISNULL(TV.AvoidableFlagID,0)=0 THEN UD.AvoidableFlagID   
ELSE TV.AvoidableFlagID END) <> UD.AvoidableFlagID  
OR (CASE WHEN ISNULL(TV.ResidualDebtID,0)=0 THEN UD.ResidualDebtID   
ELSE TV.ResidualDebtID END) <> UD.ResidualDebtID)  
   
---Uploaded Data load on signoff    
    
UPDATE TV SET TV.DebtClassificationID=UD.DebtClassificationID,    
TV.AvoidableFlagID = UD.AvoidableFlagID, TV.ResidualDebtID = UD.ResidualDebtID,    
TV.ModifiedBy= @UserId,TV.ModifiedDate=GetDate()  
FROM [ML].[TRN_ClusteringTicketValidation_App](NOLOCK) TV     
JOIN [ML].[TRN_ClusteringOutcomeUploadedData_App](NOLOCK) UD ON     
UD.TicketID = TV.TicketID and UD.MLTransactionId = TV.MLTransactionId    
WHERE TV.MLTransactionId=@TransactionId    
   
--UPDATE TICKETDetail Table    
    
 UPDATE TV SET TV.DebtClassificationMapID=UD.DebtClassificationID,    
TV.AvoidableFlag = UD.AvoidableFlagID, TV.ResidualDebtMapID = UD.ResidualDebtID,  
TV.LastUpdatedDate=GetDate(),TV.ModifiedBy=@UserId,TV.ModifiedDate=GetDate()  
,TV.DebtClassificationMode = CASE WHEN (ISNULL(UD.DebtClassificationID,0) <> 0 AND ISNULL(UD.AvoidableFlagID,0)<>0 AND ISNULL(ResidualDebtID,0) <> 0)  
THEN 5 ELSE TV.DebtClassificationMode END,  
TV.IsApproved=1    
FROM [AVL].[TK_TRN_TicketDetail] TV     
JOIN [ML].[TRN_ClusteringOutcomeUploadedData_App](NOLOCK) UD ON     
UD.TicketID = TV.TicketID AND UD.ProjectId=TV.ProjectId AND UD.ApplicationId=TV.ApplicationId    
WHERE TV.ProjectId=@projectId    
  
DELETE FROM [ML].[TRN_ClusteringOutcomeUploadedData_App] WHERE MLTransactionId = @TransactionId  
    
SET @ClusterTotal = (select count(ClusterID_Desc)  as Total                                      
from [ML].[TRN_ClusteringTicketValidation_App] where MLTransactionId = @TransactionId AND IsDeleted=0 AND (ISNULL(ClusterID_Desc,0)!= 0                 
 OR ISNULL(ClusterID_Resolution,0)!= 0)                                    
)                   
                  
--set @ResolutionTotal = (select count(ClusterID_Resolution) as Total                                      
--from [ML].[TRN_ClusteringTicketValidation_App] where MLTransactionId = @TransactionId AND ClusterID_Resolution !=0)                     
                  
UPDATE AVL.Mas_projectDebtDetails SET MLSignOffDate = Getdate(),ismlsignoff=1 WHERE ProjectID = @projectId                   
AND MLSignOffDate IS  NULL                                  
END                  
ELSE                  
BEGIN 
--UPDATE IsOverWrite Flag    
    
UPDATE TV SET TV.IsOverwrite=1  , TV.ModifiedBy = @UserId , TV.ModifiedDate= GetDate()  
FROM [ML].[TRN_ClusteringTicketValidation_Infra](NOLOCK) TV     
JOIN [ML].[TRN_ClusteringOutcomeUploadedData_Infra](NOLOCK) UD ON     
UD.MLTransactionId = TV.MLTransactionId AND UD.TicketID = TV.TicketID    
WHERE TV.MLTransactionId = @TransactionId     
AND ((CASE WHEN ISNULL(TV.DebtClassificationID,0)=0 THEN UD.DebtClassificationID   
ELSE TV.DebtClassificationID END) <> UD.DebtClassificationID   
OR (CASE WHEN ISNULL(TV.AvoidableFlagID,0)=0 THEN UD.AvoidableFlagID   
ELSE TV.AvoidableFlagID END) <> UD.AvoidableFlagID  
OR (CASE WHEN ISNULL(TV.ResidualDebtID,0)=0 THEN UD.ResidualDebtID   
ELSE TV.ResidualDebtID END) <> UD.ResidualDebtID)  
   
---Uploaded Data load on signoff    
    
UPDATE TV SET TV.DebtClassificationID=UD.DebtClassificationID,    
TV.AvoidableFlagID = UD.AvoidableFlagID, TV.ResidualDebtID = UD.ResidualDebtID,    
TV.ModifiedBy= @UserId,TV.ModifiedDate=GetDate()  
FROM [ML].[TRN_ClusteringTicketValidation_Infra](NOLOCK) TV     
JOIN [ML].[TRN_ClusteringOutcomeUploadedData_Infra](NOLOCK) UD ON     
UD.TicketID = TV.TicketID and UD.MLTransactionId = TV.MLTransactionId    
WHERE TV.MLTransactionId=@TransactionId    
   
--UPDATE TICKETDetail Table    
    
 UPDATE TV SET TV.DebtClassificationMapID=UD.DebtClassificationID,    
TV.AvoidableFlag = UD.AvoidableFlagID, TV.ResidualDebtMapID = UD.ResidualDebtID,  
TV.LastUpdatedDate=GetDate(),TV.ModifiedBy=@UserId,TV.ModifiedDate=GetDate()  
,TV.DebtClassificationMode = CASE WHEN (ISNULL(UD.DebtClassificationID,0) <> 0 AND ISNULL(UD.AvoidableFlagID,0)<>0 AND ISNULL(ResidualDebtID,0) <> 0)  
THEN 5 ELSE TV.DebtClassificationMode END,  
TV.IsApproved=1    
FROM [AVL].[TK_TRN_InfraTicketDetail] TV     
JOIN [ML].[TRN_ClusteringOutcomeUploadedData_Infra](NOLOCK) UD ON     
UD.TicketID = TV.TicketID AND UD.ProjectId=TV.ProjectId AND UD.TowerId=TV.TowerId    
WHERE TV.ProjectId=@projectId    
  
DELETE FROM [ML].[TRN_ClusteringOutcomeUploadedData_Infra] WHERE MLTransactionId = @TransactionId  

SET @ClusterTotal = (select count(ClusterID_Desc)  as Total                                      
from [ML].[TRN_ClusteringTicketValidation_Infra] where MLTransactionId = @TransactionId AND IsDeleted=0 AND (ISNULL(ClusterID_Desc,0)!= 0                 
 OR ISNULL(ClusterID_Resolution,0)!= 0)                                    
)                    
                  
--set @ResolutionTotal = (select count(ClusterID_Resolution) as Total                                      
--from [ML].[TRN_ClusteringTicketValidation_Infra] where MLTransactionId = @TransactionId AND ClusterID_Resolution !=0)                     
                  
UPDATE AVL.Mas_projectDebtDetails SET MLSignOffDateInfra = Getdate(),IsMLSignOffInfra=1 WHERE ProjectID = @projectId                   
AND MLSignOffDateInfra IS  NULL                  
END                  
                    
                  
                    
--SET @Total = @ClusterTotal +@ResolutionTotal                          
              --select * from [ML].[TRN_AuditLog] where MLTransactionId = 834            
     update [ML].[TRN_AuditLog] set Total = @ClusterTotal, SignOffDate = GETDATE(),SignOffBy=@UserId,ModifiedBy = @UserId,ModifiedDate=GETDATE() where MLTransactionId = @TransactionId and LearningTypeKey ='LT002'            
--INSERT INTO [ML].[TRN_AuditLog](MLTransactionId, SignOffDate, Total, ModelVersion, PRFromDate, PRToDate, IsDeleted, CreatedBy,CreatedDate, LearningTypeKey, SignOffBy)                             
--VALUES(@TransactionId,GETDATE(),@ClusterTotal,@ModelVersion + 1,@PRFromDate,@PRToDate,0,@UserId,GETDATE(),'LT002',@UserId)                          
                          
--------------------------------------------------------------------------                        
COMMIT TRAN                  
END TRY                                                                    
BEGIN CATCH                                                                   
    ROLLBACK TRAN                                                                    
  DECLARE @ErrorMessage VARCHAR(MAX);                                                                  
  SELECT @ErrorMessage = ERROR_MESSAGE()                                                    
                                                                           
  EXEC AVL_InsertError '[ML].[SaveSignOff]', @ErrorMessage, 0,0                                                     
                                                                    
 END CATCH                                                                     
END 