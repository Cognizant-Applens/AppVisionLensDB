CREATE PROCEDURE [ML].[GetMLTransactionDetailsBIId]                      
@TransacrionId int                     
 AS                
 BEGIN      
 BEGIN TRY       
 SET NOCOUNT ON           
  select TransactionId,ProjectId,IssueDefinitionId,a.ResolutionProviderId,b.CategoricalFieldId,a.FromDate,a.ToDate,a.IsNoiseEnabled from [ML].[TRN_MLTransaction] a            
  LEFT JOIN [ML].[TRN_TransactionCategorical] b on a.TransactionId = b.MLTransactionId and a.IsDeleted=0 and b.IsDeleted=0            
  where a.TransactionId=@TransacrionId and a.IsDeleted=0     
   SET NOCOUNT OFF;          
  END TRY          
  BEGIN CATCH          
        DECLARE @ErrorMessage VARCHAR(MAX);          
  SELECT @ErrorMessage = ERROR_MESSAGE()          
  --INSERT Error              
  EXEC AVL_InsertError '[ML].[GetMLTransactionDetailsBIId]', @ErrorMessage,null          
  END CATCH     
  END
