CREATE PROCEDURE [ML].[GetDataQualityJobStatus]                                
@TransactionId BIGINT      
AS                                      
BEGIN                                             
BEGIN TRY                       
      
  SELECT DQVStatusKey FROM [ML].[TRN_MLTransaction] WHERE TransactionId=@TransactionId              
            
END TRY                                            
BEGIN CATCH                                            
                                                         
  DECLARE @ErrorMessage VARCHAR(MAX);                                          
  SELECT @ErrorMessage = ERROR_MESSAGE()                                         
                                                   
  EXEC AVL_InsertError '[ML].[GetDataQualityJobStatus]', @ErrorMessage, 0,0                                          
                                            
 END CATCH                                             
END
