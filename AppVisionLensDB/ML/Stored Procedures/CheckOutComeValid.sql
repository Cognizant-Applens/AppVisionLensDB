CREATE PROCEDURE [ML].[CheckOutComeValid]            
@TransactionId bigint            
AS             
BEGIN            
BEGIN TRY            
DECLARE @Result int         
 IF(SElect Count(Signoffdate) from ML.TRN_MLTransaction  WHERE TransactionId = @TransactionId AND IsDeleted = 0 AND Signoffdate IS NOT NULL) > 0        
 BEGIN        
      
 SET @Result =             
CASE             
WHEN (SELECT COUNT(TransactionId) FROM ML.ClusteringCLProjects(NOLOCK) WHERE TransactionId = @TransactionId) >0  
AND (SELECT Jobstatuskey FROM ML.ClusteringCLProjects(NOLOCK) WHERE TransactionId = @TransactionId) IS NULL THEN 0              
ELSE 1 END       
         
 END        
 ELSE      
 BEGIN      
SET @Result =             
CASE             
WHEN (SELECT Jobstatuskey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE TransactionId = @TransactionId) = 'SK001' THEN 1               
WHEN (SELECT Jobstatuskey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE TransactionId = @TransactionId) = 'SK002' THEN 1   
WHEN (SELECT Jobstatuskey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE TransactionId = @TransactionId) = 'SK005' THEN 1               
WHEN (SELECT Jobstatuskey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE TransactionId = @TransactionId) = 'SK006' THEN 1  
WHEN (SELECT Jobstatuskey FROM [ML].[TRN_MLTransaction](NOLOCK) WHERE TransactionId = @TransactionId) = 'SK007' THEN 1   
ELSE 0 END       
      
END      
      
SELECT @Result            
END TRY            
BEGIN CATCH                                                
                                                             
  DECLARE @ErrorMessage VARCHAR(MAX);                                              
  SELECT @ErrorMessage = ERROR_MESSAGE()                                             
                                                       
  EXEC AVL_InsertError '[ML].[CheckOutComeValid]', @ErrorMessage, 0,0                                              
                                                
 END CATCH              
END
