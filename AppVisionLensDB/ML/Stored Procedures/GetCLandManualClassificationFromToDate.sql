    
CREATE PROCEDURE [ML].[GetCLandManualClassificationFromToDate]  --1120,0                
@TransactionId BIGINT,    
@IsManual BIT    
AS                                  
BEGIN                                         
BEGIN TRY                    
      
BEGIN    
DECLARE @IsApp bit;   
SET @IsApp =(Select Case when SupportTypeId=1 THEN 1 ELSE 0 END   from ML.TRN_MLTransaction WHERE TransactionId=@TransactionId);  

DECLARE @LastJobRunDate date;  
IF(@IsApp = 1)  
BEGIN  
SET @LastJobRunDate =(SELECT TOP 1 CLJobRunDate from [ML].[TRN_ClusteringTicketValidation_App] (NOLOCK)  WHERE MLTransactionId=@TransactionId ORDER BY CLJobRunDate desc )  --SELECT @LastJobRunDate    
END
ELSE
BEGIN
SET @LastJobRunDate =(SELECT TOP 1 CLJobRunDate from [ML].[TRN_ClusteringTicketValidation_Infra] (NOLOCK)  WHERE MLTransactionId=@TransactionId ORDER BY CLJobRunDate desc )  --SELECT @LastJobRunDate    
END

SELECT @LastJobRunDate AS 'LastJobRunDate'    
  
SELECT CMRD.FromDate,CMRD.ToDate  FROM   
[ML].[CLandManualClassificationReviewDetails] CMRD (NOLOCK)      
LEFT JOIN ML.ClusteringCLProjects CLP ON CLP.TransactionId = CMRD.MLTransactionId  and CLP.JobStatusKey = 'SK002'    
WHERE CMRD.MLTransactionId = @TransactionId and CMRD.IsManual = @IsManual AND CMRD.Isdeleted=0  
ORDER BY CLP.JobRunDate DESC    
   
END    
        
END TRY                                        
BEGIN CATCH                                        
                                                     
DECLARE @ErrorMessage VARCHAR(MAX);                                      
SELECT @ErrorMessage = ERROR_MESSAGE()                                     
                                               
EXEC AVL_InsertError '[ML].[GetCLandManualClassificationFromToDate]', @ErrorMessage, 0,0                                      
                                        
 END CATCH                                         
END    