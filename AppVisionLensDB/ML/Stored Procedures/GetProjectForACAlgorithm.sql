CREATE PROCEDURE [ML].[GetProjectForACAlgorithm] (@StatusId INT)    
AS    
BEGIN    
BEGIN TRY        
 SET NOCOUNT ON;    
 
 Update [ML].[AutoClassificationBatchProcess] set isdeleted = 1
 where statusid=13 AND isdeleted !=1 AND
 batchprocessid not in (select distinct batchprocessid from [ML].[TicketsforAutoClassification] (NOLOCK))
 
 SELECT TOP 200 BatchProcessId,ProjectId FROM  ML.AutoClassificationBatchProcess WHERE StatusId=@StatusId AND IsDeleted=0
    
 END TRY        
BEGIN CATCH        
DECLARE @ErrorMessage VARCHAR(MAX);        
        
  SELECT @ErrorMessage = ERROR_MESSAGE()        
        
  --INSERT Error            
  EXEC AVL_InsertError '[dbo].[GetProjectForACAlgorithm]', @ErrorMessage ,''        
END CATCH        
    
END