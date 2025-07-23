CREATE PROCEDURE [ML].[UpdateDataQualityJobStatus]                                 
@TransactionId BIGINT        
AS                                        
BEGIN                                               
BEGIN TRY                         
        
 UPDATE [ML].[TRN_MLTransaction] SET DQVStatusKey='SK001',NoiseStatusKey='SK001',ScreenId=3 WHERE TransactionId=@TransactionId           
         
              
END TRY                                              
BEGIN CATCH                                              
                                                           
  DECLARE @ErrorMessage VARCHAR(MAX);                                            
  SELECT @ErrorMessage = ERROR_MESSAGE()                                           
                                                     
  EXEC AVL_InsertError '[ML].[UpdateDataQualtiyJobStatus]', @ErrorMessage, 0,0                                            
                                              
 END CATCH                                               
END
