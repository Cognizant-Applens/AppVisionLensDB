
CREATE PROCEDURE [ML].[IsNoiseEnabled]    
@TransactionId BIGINT    
AS     
BEGIN    
  BEGIN TRY    
 SET NOCOUNT ON;   
  Select IsNoiseEnabled FROM ML.TRN_MLTransaction     
  where TransactionId = @TransactionId AND IsDeleted = 0     
 SET NOCOUNT OFF;    
  END TRY    
  BEGIN CATCH    
        DECLARE @ErrorMessage VARCHAR(MAX);    
  SELECT @ErrorMessage = ERROR_MESSAGE()    
  --INSERT Error        
  EXEC AVL_InsertError '[ML].[IsNoiseEnabled]', @ErrorMessage,null    
  END CATCH     
END
