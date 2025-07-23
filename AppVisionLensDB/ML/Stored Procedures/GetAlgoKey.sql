CREATE Procedure [ML].[GetAlgoKey]  
@ProjectId int,  
@SupportTypeId int  
As  
Begin  
  
SELECT AlgorithmKey,TransactionId FROM [ML].[TRN_MLTransaction] WHERE ProjectId = @ProjectId and SupportTypeId=@SupportTypeId  
and IsActiveTransaction=1  
  
SELECT FN.TK_TicketDetailColumn      
FROM [ML].[TRN_MLTransaction] MT      
 JOIN [ML].[TRN_TransactionCategorical] MD ON MD.MLTransactionId=MT.TransactionId       
JOIN [MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=MD.CategoricalFieldId       
and MT.SupportTypeId=@SupportTypeId  
WHERE ProjectId= @ProjectId  AND ISNULL(MT.IsActiveTransaction,0)=1      
UNION      
(SELECT FN.TK_TicketDetailColumn FROM [ML].[TRN_MLTransaction] t LEFT join       
[MAS].[ML_Prerequisite_FieldMapping] FN ON FN.FieldMappingId=t.IssueDefinitionId      
or FN.FieldMappingId=t.ResolutionProviderId          
WHERE t.ProjectId= @ProjectId and t.SupportTypeId=@SupportTypeId AND ISNULL(t.IsActiveTransaction,0)=1 )      
      
End
