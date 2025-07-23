CREATE PROC [ML].[UpdateDataQualityFreezeStatus] -- 689                
@TransactionID BIGINT,                
@IsFreeze BIT             
AS                      
BEGIN                       
BEGIN TRY        
    
DECLARE @SupportTypeId int = (Select Top 1 SupportTypeId from ML.TRN_MLTRANSACTION(NOLOCK) WHERE TransactionID =@TransactionID)    
    
IF( @SupportTypeId = 1)    
BEGIN    
    
UPDATE [ML].[TRN_ClusteringTicketValidation_App] SET IsFreeze = @IsFreeze Where MLTransactionID =@TransactionID AND ISSelected=1    
UPDATE [ML].[TRN_ClusteringTicketValidation_App] SET IsFreeze = 0 Where MLTransactionID =@TransactionID AND ISSelected=0    
    
END    
ELSE    
BEGIN      
    
UPDATE [ML].[TRN_ClusteringTicketValidation_Infra] SET IsFreeze = @IsFreeze Where MLTransactionID =@TransactionID AND ISSelected=1    
UPDATE [ML].[TRN_ClusteringTicketValidation_Infra] SET IsFreeze = 0 Where MLTransactionID =@TransactionID AND ISSelected=0    
END    
      
END TRY                      
BEGIN CATCH                                                  
                                                 
 DECLARE @ErrorMessage NVARCHAR(4000);                                                            
 DECLARE @ErrorSeverity INT;                                                            
 DECLARE @ErrorState INT;                                                            
                                                            
select @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();                                                
                              
   --INSERT Error                                                            
   EXEC AVL_InsertError 'ML.[UpdateDataQualityFreezeStatus]',@ErrorMessage ,0,0                         
                                                        
END CATCH                                                         
END 