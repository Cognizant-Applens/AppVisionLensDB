CREATE PROC [ML].[UpdateRegenerateAuditLog]      
@TransactionId int,      
@FromDate Date,                                                        
@ToDate Date,       
@UserId NVarchar(50)      
AS        
 BEGIN      
 BEGIN TRY        
 SET NOCOUNT ON;       
 IF NOT EXISTS(SELECT * FROM [ML].[TRN_AuditLog](NOLOCK) WHERE MLTransactionId = @TransactionId AND LearningTypeKey = 'LT003' AND   
 CONVERT(date, ModifiedDate) < CONVERT(date, GETDATE()))      
 BEGIN       
 DECLARE @SignOffDate date = (SELECT SignOffDate FROM ML.TRN_MLTransaction(NOLOCK) WHERE TransactionId = @TransactionId)      
 DECLARE @ModelVersion int = (SELECT max(ModelVersion)+1 FROM  ML.[TRN_AuditLog](NOLOCK) WHERE MLTransactionId = @TransactionId)  
   
 INSERT INTO [ML].[TRN_AuditLog]      
 (MLTransactionId,SignOffDate,Total,ModelVersion,PRFromDate,PRToDate,IsDeleted,CreatedBy,CreatedDate,LearningTypeKey)       
 VALUES (@TransactionId,@SignOffDate,NULL,@ModelVersion,@FromDate,@ToDate,0,@UserId,Getdate(),'LT003')      
 END      
 ELSE       
 BEGIN      
 UPDATE [ML].[TRN_AuditLog] SET PRFromDate = @FromDate,PRToDate = @ToDate,ModifiedBy = @UserId,ModifiedDate = Getdate()  WHERE MLTransactionId = @TransactionId AND LearningTypeKey = 'LT003'  
 END      
 END TRY          
BEGIN CATCH          
 DECLARE @ErrorMessage VARCHAR(8000);        
 SELECT @ErrorMessage = ERROR_MESSAGE()        
 --INSERT Error            
 EXEC AVL_InsertError '[ML].[UpdatePrerequisiteAuditLog]', @ErrorMessage, 0        
END CATCH          
END
