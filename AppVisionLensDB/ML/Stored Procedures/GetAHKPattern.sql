CREATE PROCEDURE [ML].[GetAHKPattern]         
@TransactionId BIGINT         
AS         
BEGIN        
  BEGIN TRY        
 SET NOCOUNT ON;        
SELECT ResolutionProviderId,TC.CategoricalFieldId,PFM.ITSMColumn from ML.TRN_MLTransaction TRA      
INNER JOIN [ML].[TRN_TransactionCategorical] TC ON TRA.TransactionId = TC.MLTransactionId      
LEFT JOIN [MAS].[ML_Prerequisite_FieldMapping] PFM      
ON TC.CategoricalFieldId = PFM.FieldMappingId      
WHERE TRA.TransactionId = @TransactionId AND TRA.Isdeleted = 0 AND TC.IsDeleted = 0 AND PFM.IsDeleted = 0        
 SET NOCOUNT OFF;        
  END TRY        
  BEGIN CATCH        
        DECLARE @ErrorMessage VARCHAR(MAX);        
  SELECT @ErrorMessage = ERROR_MESSAGE()        
  --INSERT Error            
  EXEC AVL_InsertError '[ML].[GetAHKPattern]', @ErrorMessage,null        
  END CATCH         
END
