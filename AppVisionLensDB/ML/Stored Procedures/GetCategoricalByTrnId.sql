CREATE PROCEDURE [ML].[GetCategoricalByTrnId]         
@TransactionId BIGINT         
AS       
BEGIN      
  BEGIN TRY      
 SET NOCOUNT ON;       
 Select TC.CategoricalFieldId,PFM.ITSMColumn AS CategoricalField      
    FROM ML.TRN_TransactionCategorical TC      
    LEFT JOIN [MAS].[ML_Prerequisite_FieldMapping] PFM      
    ON TC.CategoricalFieldId = PFM.FieldMappingId      
    where TC.MLTransactionId = @TransactionId AND TC.IsDeleted = 0 AND PFM.IsDeleted = 0          
      
 SET NOCOUNT OFF;      
  END TRY      
  BEGIN CATCH      
        DECLARE @ErrorMessage VARCHAR(MAX);      
  SELECT @ErrorMessage = ERROR_MESSAGE()      
  --INSERT Error          
  EXEC AVL_InsertError '[ML].[GetCategoricalByTrnId]', @ErrorMessage,null      
  END CATCH       
END
