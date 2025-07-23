
CREATE PROCEDURE [ML].[GetOutComeParams]       
       
AS       
BEGIN      
  BEGIN TRY      
 SET NOCOUNT ON;      
    SELECT AlgorithmId,AlgorithmName,AlgorithmKey FROM [MAS].[MLAlgorithm] where IsDeleted = 0;      
 SET NOCOUNT OFF;      
  END TRY      
  BEGIN CATCH      
        DECLARE @ErrorMessage VARCHAR(MAX);      
  SELECT @ErrorMessage = ERROR_MESSAGE()      
  --INSERT Error          
  EXEC AVL_InsertError '[ML].[GetOutComeParams]', @ErrorMessage,null      
  END CATCH       
END
