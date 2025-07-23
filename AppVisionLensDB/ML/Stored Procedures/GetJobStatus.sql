CREATE PROCEDURE [ML].[GetJobStatus]                          
@TransactionId BIGINT,  
@isRegenerate BIT  
AS                                
BEGIN                                       
BEGIN TRY                 
     
 IF(@isRegenerate=0)    
 BEGIN  
 SELECT JobMessage,JobStatusKey FROM [ML].[TRN_MLTransaction] WHERE TransactionId=@TransactionId    
 END  
 ELSE  
 BEGIN  
  SELECT JobMessage,JobStatusKey FROM [ML].[ClusteringCLProjects] WHERE TransactionId=@TransactionId    
END  
      
END TRY                                      
BEGIN CATCH                                      
                                                   
  DECLARE @ErrorMessage VARCHAR(MAX);                                    
  SELECT @ErrorMessage = ERROR_MESSAGE()                                   
                                             
  EXEC AVL_InsertError '[ML].[GetJobStatus]', @ErrorMessage, 0,0                                    
                                      
 END CATCH                                       
END
