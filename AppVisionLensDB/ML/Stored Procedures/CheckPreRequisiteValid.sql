CREATE PROC [ML].[CheckPreRequisiteValid]      
@TransactionId bigint        
AS         
BEGIN        
BEGIN TRY        
DECLARE @Result int      
DECLARE @SupportTypeId int = (SELECT SupportTypeId from [ML].[TRN_MLTRANSACTION](NOLOCK) WHERE TransactionId = @TransactionId)  
IF (@SupportTypeId =1)  
BEGIN  
SET @Result =         
CASE WHEN (SELECT COUNT(*) FROM [ML].[TRN_DataQuality_Outcome_app](NOLOCK) WHERE MLTransactionId = @TransactionId) > 0 THEN 1 ELSE 0 END    
END  
ELSE  
BEGIN  
SET @Result =         
CASE WHEN (SELECT COUNT(*) FROM [ML].[TRN_DataQuality_Outcome_Infra](NOLOCK) WHERE MLTransactionId = @TransactionId) > 0 THEN 1 ELSE 0 END    
END  
SELECT @Result  AS Result      
END TRY        
BEGIN CATCH                                            
                                                         
  DECLARE @ErrorMessage VARCHAR(MAX);                                          
  SELECT @ErrorMessage = ERROR_MESSAGE()                                         
                                                   
  EXEC AVL_InsertError '[ML].[CheckPreRequisiteValid]', @ErrorMessage, 0,0                                          
                                            
 END CATCH          
END
