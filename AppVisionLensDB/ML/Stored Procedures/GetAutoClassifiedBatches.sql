CREATE PROCEDURE [ML].[GetAutoClassifiedBatches]   
AS  
BEGIN  
BEGIN TRY 
  
 SELECT Distinct BatchProcessId,BP.ProjectId,BP.CreatedBy,SupportTypeId,MC.IsDDAutoClassified,MC.DDAutoClassificationDate,MC.IsAutoClassified  
 FROM ML.DebtAutoClassificationBatchProcess (NOLOCK) BP  
 JOIN AVL.TK_ProjectForMLClassification (NOLOCK) MC  
 ON MC.AutoClassificationDetailsID = BP.AutoClassificationDetailsId   
 WHERE StatusId IN (15,16) and BP.isdeleted=0
   
END TRY  
 BEGIN CATCH  
 DECLARE @ErrorMessage VARCHAR(MAX);  
 SELECT @ErrorMessage = ERROR_MESSAGE()  
 --INSERT Error      
 EXEC AVL_InsertError '[ML].[GetAutoClassifiedBatches]', @ErrorMessage ,''  
 END CATCH  
END  