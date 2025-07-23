  
CREATE PROCEDURE [ML].[GetClusterOutcomeUploadedData]  --[ML].[GetClusterOutcomeUploadedData] 1282
@TransactionId BIGINT                
AS                 
BEGIN                
BEGIN TRY                
DECLARE @Result int  
DECLARE @SupportTypeId int = (SELECT SupportTypeId FROM [ML].[TRN_MLTransaction] WHERE TransactionId=@TransactionId)

IF(@SupportTypeId=1)
BEGIN                     
SET @Result = CASE WHEN (SELECT COUNT(MLTransactionId) FROM ML.TRN_ClusteringOutcomeUploadedData_App(NOLOCK) WHERE MLTransactionId = @TransactionId) >0 THEN  1  ELSE 0 END           
END                  
ELSE
BEGIN
SET @Result = CASE WHEN (SELECT COUNT(MLTransactionId) FROM ML.TRN_ClusteringOutcomeUploadedData_Infra(NOLOCK) WHERE MLTransactionId = @TransactionId) >0 THEN  1  ELSE 0 END           
END
SELECT @Result                
END TRY                
BEGIN CATCH                                                    
                                                                 
  DECLARE @ErrorMessage VARCHAR(MAX);                                                  
  SELECT @ErrorMessage = ERROR_MESSAGE()                                                 
                                                           
  EXEC AVL_InsertError '[ML].[GetClusterOutcomeUploadedData]', @ErrorMessage, 0,0                                                  
                                                    
 END CATCH                  
END  
