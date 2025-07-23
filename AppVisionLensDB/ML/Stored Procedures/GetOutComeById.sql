 CREATE PROCEDURE [ML].[GetOutComeById]  
@TransactionId BIGINT          
AS           
BEGIN          
  BEGIN TRY          
 SET NOCOUNT ON;          
 Select MLTransactionId, MinimumPoint, Threshold, ThresholdRange, Level2Id          
  FROM ML.TRN_OutCome            
  where MLTransactionId = @TransactionId AND IsDeleted = 0            
 SET NOCOUNT OFF;          
  END TRY          
  BEGIN CATCH          
        DECLARE @ErrorMessage VARCHAR(MAX);          
  SELECT @ErrorMessage = ERROR_MESSAGE()          
  --INSERT Error              
  EXEC AVL_InsertError '[ML].[GetOutComeById]', @ErrorMessage,null          
  END CATCH           
END
