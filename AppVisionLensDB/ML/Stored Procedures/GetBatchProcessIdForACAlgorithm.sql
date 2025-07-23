CREATE PROCEDURE [ML].[GetBatchProcessIdForACAlgorithm]         
 -- Add the parameters for the stored procedure here        
AS        
BEGIN        
     
 SET NOCOUNT ON;        
 BEGIN TRY    
 SELECT Distinct BatchProcessId,ProjectId,CreatedBy,IsDDAutoClassified,IsAutoClassified--MC.DDAutoClassificationDate    
 FROM ML.AutoClassificationBatchProcess(NOLOCK)    
 WHERE StatusId in(15,16)  OR (StatusId=13 AND ISNULL(ModifiedDate,'')<>'' AND ISNULL(TransactionIdApp,0)=0 AND ISNULL(TransactionIdInfra,0)=0)      
 END TRY    
 BEGIN CATCH    
 DECLARE @ErrorMessage VARCHAR(MAX);    
 SELECT @ErrorMessage = ERROR_MESSAGE()    
 --INSERT Error        
 EXEC AVL_InsertError '[ML].[GetBatchProcessIdForACAlgorithm]', @ErrorMessage ,''    
 END CATCH    
END 