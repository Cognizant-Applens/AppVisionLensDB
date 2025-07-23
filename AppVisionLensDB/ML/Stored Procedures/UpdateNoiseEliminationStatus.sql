CREATE PROCEDURE [ML].[UpdateNoiseEliminationStatus]                               
@TransactionId BIGINT        
AS                                        
BEGIN                                               
BEGIN TRY                         
        
 UPDATE [ML].[TRN_MLTransaction] SET NoiseStatusKey='SK001' WHERE TransactionId=@TransactionId           
         
              
END TRY                                              
BEGIN CATCH                                              
                                                           
  DECLARE @ErrorMessage VARCHAR(MAX);                                            
  SELECT @ErrorMessage = ERROR_MESSAGE()                                           
                                                     
  EXEC AVL_InsertError '[ML].[UpdateNoiseEliminationStatus]', @ErrorMessage, 0,0                                            
                                              
 END CATCH                                               
END
