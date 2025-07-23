CREATE PROCEDURE [ML].[GetColumnMappingForProject]   --143286  ,18                     
(@ProjectId INT,@BatchProcessId INT)                        
AS                        
BEGIN                       
BEGIN TRY                            
 SET NOCOUNT ON;                         
                      
SELECT DISTINCT SupportType  INTO #temp FROM ML.TicketsforAutoClassification WHERE BatchProcessId in(@BatchProcessId)              
              
SELECT FN.ITSMColumn              
FROM [ML].[TRN_MLTransaction] MT              
 JOIN [ML].[TRN_TransactionCategorical] MD ON MD.MLTransactionId=MT.TransactionId               
JOIN [MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=MD.CategoricalFieldId               
JOIN #temp t on t.SupportType=MT.SupportTypeId              
WHERE ProjectId= @ProjectId  AND t.SupportType=1 AND ISNULL(MT.IsActiveTransaction,0)=1 AND MT.IsDeleted=0              
UNION              
(SELECT FN.ITSMColumn FROM [ML].[TRN_MLTransaction] t LEFT join               
[MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=t.IssueDefinitionId              
or FN.FieldMappingId=t.ResolutionProviderId               
JOIN #temp te on te.SupportType=t.SupportTypeId              
WHERE t.ProjectId= @ProjectId and te.SupportType=1 AND ISNULL(t.IsActiveTransaction,0)=1 AND t.IsDeleted=0)        
              
--infra              
              
SELECT FN.ITSMColumn              
FROM [ML].[TRN_MLTransaction] MT              
 JOIN [ML].[TRN_TransactionCategorical] MD ON MD.MLTransactionId=MT.TransactionId               
JOIN [MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=MD.CategoricalFieldId               
JOIN #temp t ON t.SupportType=MT.SupportTypeId              
WHERE ProjectId= @ProjectId  AND t.SupportType=2 AND ISNULL(MT.IsActiveTransaction,0)=1 AND MT.IsDeleted=0             
UNION              
(SELECT FN.ITSMColumn from [ML].[TRN_MLTransaction] t left join               
[MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=t.IssueDefinitionId              
or fn.FieldMappingId=t.ResolutionProviderId               
JOIN #temp te ON te.SupportType=t.SupportTypeId              
WHERE t.ProjectId= @ProjectId AND te.SupportType=2 AND ISNULL(t.IsActiveTransaction,0)=1 AND t.IsDeleted=0)              
              
          
UPDATE           
    t1          
SET           
    t1.TransactionIdApp=MT.TransactionId        
FROM  ML.AutoClassificationBatchProcess t1          
JOIN [ML].[TRN_MLTransaction] MT ON MT.ProjectId=t1.ProjectId          
JOIN #temp te ON te.SupportType=MT.SupportTypeId          
JOIN  ML.TicketsforAutoClassification DT ON DT.BatchProcessId=t1.BatchProcessId        
WHERE te.SupportType=1  AND DT.BatchProcessId= @BatchProcessId   AND ISNULL(MT.IsActiveTransaction,0)=1 AND MT.IsDeleted=0       
          
          
UPDATE           
    t1          
SET           
    t1.TransactionIdInfra=MT.TransactionId        
FROM  ML.AutoClassificationBatchProcess t1          
JOIN [ML].[TRN_MLTransaction] MT ON MT.ProjectId=t1.ProjectId          
JOIN #temp te ON te.SupportType=MT.SupportTypeId          
JOIN  ML.TicketsforAutoClassification DT ON DT.BatchProcessId=t1.BatchProcessId        
WHERE te.SupportType=2   AND DT.BatchProcessId= @BatchProcessId  AND ISNULL(MT.IsActiveTransaction,0)=1 AND MT.IsDeleted=0        
          
DROP TABLE #temp              
              
                     
END TRY                            
BEGIN CATCH                            
DECLARE @ErrorMessage VARCHAR(MAX);                            
                            
  SELECT @ErrorMessage = ERROR_MESSAGE()                            
                            
  --INSERT Error                                
  EXEC AVL_InsertError '[dbo].[GetColumnMappingForProject]', @ErrorMessage ,''                            
END CATCH                              
END
