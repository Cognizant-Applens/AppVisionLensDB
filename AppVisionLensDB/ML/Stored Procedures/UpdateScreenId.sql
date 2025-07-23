CREATE PROC [ML].[UpdateScreenId]      
@TransactionId BIGINT,      
@ScreenID int      
AS       
BEGIN      
BEGIN TRY      
BEGIN TRAN    
 UPDATE [ML].[TRN_MLTransaction] SET ScreenId = @ScreenID WHERE TransactionID = @TransactionId      
COMMIT TRAN     
END TRY        
BEGIN CATCH                                            
      ROLLBACK TRAN                                                   
  DECLARE @ErrorMessage VARCHAR(MAX);                                          
  SELECT @ErrorMessage = ERROR_MESSAGE()                                         
                                                   
  EXEC AVL_InsertError '[ML].[UpdateScreenId]', @ErrorMessage, 0,0                                          
                                            
 END CATCH          
END
