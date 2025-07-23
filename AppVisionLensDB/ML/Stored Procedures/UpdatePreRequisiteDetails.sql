        
        
        
                 
CREATE PROCEDURE [ML].[UpdatePreRequisiteDetails]                                                
 @TransactionId bigint,                                              
 @ApplicationId nvarchar(MAX),                                        
 @CreatedBy Varchar(50),                                        
 @IsApp Bit,                              
 @IsAppChanged Bit                              
AS                                                
BEGIN                                                
 SET NOCOUNT ON;                                              
 BEGIN TRY                                                
     BEGIN TRAN      
   DECLARE @IsSignOff bit;    
  
   IF EXISTS(Select SignOffDate FROM ML.TRN_MLTransaction WHERE TransactionId=@TransactionId AND SignOffDate IS NOT NULL)    
   BEGIN    
   SET @IsSignOff= 1;    
   END    
   ELSE    
   BEGIN    
   SET @IsSignOff= 0;    
   END    
 -- Logic to update the Selected Application ID for the Transaction                                        
 IF(@IsApp = 1)                                        
 BEGIN     
   
    
  UPDATE [ML].TRN_DataQuality_OutCome_App SET                                        
  IsSelected = 0,                                        
  ModifiedBy = @CreatedBy,                                        
  ModifiedDate = GETDATE()                                        
  WHERE MLTransactionId = @TransactionId AND IsDeleted = 0 AND                                         
  ApplicationId not in (SELECT CAST(Item AS Bigint) FROM dbo.SplitString(@ApplicationId, ','))                                        
                                  
  UPDATE [ML].TRN_DataQuality_OutCome_App SET                                        
  IsSelected = 1,                                        
  ModifiedBy = @CreatedBy,                                        
  ModifiedDate = GETDATE()                                        
  WHERE MLTransactionId = @TransactionId AND IsDeleted = 0 AND                                         
  ApplicationId in (SELECT CAST(Item AS Bigint) FROM dbo.SplitString(@ApplicationId, ','))                                        
                                
  -- Updating the Clustering Ticket Validation Table - update the selected application for transaction Id                                
                                
  UPDATE [ML].TRN_ClusteringTicketValidation_App SET                                        
  IsSelected = 0,                                        
  ModifiedBy = @CreatedBy,                                        
  ModifiedDate = GETDATE()                                        
  WHERE MLTransactionId = @TransactionId AND IsDeleted = 0 AND                                         
  ApplicationId not in (SELECT CAST(Item AS Bigint) FROM dbo.SplitString(@ApplicationId, ','))    
  
    
    UPDATE [ML].TRN_ClusteringTicketValidation_App SET                                        
 TicketType= CASE WHEN @IsSignOff=1 THEN 'LT003' ELSE 'LT002' END    
  WHERE MLTransactionId = @TransactionId AND IsDeleted = 0 AND isSelected<>1  AND                                     
  ApplicationId in (SELECT CAST(Item AS Bigint) FROM dbo.SplitString(@ApplicationId, ','))   
          
  UPDATE [ML].TRN_ClusteringTicketValidation_App SET                                        
  IsSelected = 1,                                        
  ModifiedBy = @CreatedBy,                  
  Clusterid_desc = Case When Clusterid_desc is null  THEN 0 ELSE Clusterid_desc END,                  
  ClusterID_Resolution = Case When ClusterID_Resolution is null  THEN 0 ELSE ClusterID_Resolution END,                  
  ModifiedDate = GETDATE()    
  --TicketType= CASE WHEN @IsSignOff=1 THEN 'LT003' ELSE 'LT002' END    
  WHERE MLTransactionId = @TransactionId AND IsDeleted = 0 AND                                         
  ApplicationId in (SELECT CAST(Item AS Bigint) FROM dbo.SplitString(@ApplicationId, ','))       
     
 
    
                                
             
 END                                        
 ELSE                 
 BEGIN                                  
  UPDATE [ML].TRN_DataQuality_OutCome_Infra SET                                        
  IsSelected = 0,                                        
  ModifiedBy = @CreatedBy,                                        
  ModifiedDate = GETDATE()                                        
  WHERE MLTransactionId = @TransactionId AND IsDeleted = 0 AND                                         
  TowerId not in (SELECT CAST(Item AS Bigint) FROM dbo.SplitString(@ApplicationId, ','))                                  
            
  UPDATE [ML].TRN_DataQuality_OutCome_Infra SET                                        
  IsSelected = 1,                                        
  ModifiedBy = @CreatedBy,                 
  ModifiedDate = GETDATE()                                        
  WHERE MLTransactionId = @TransactionId AND IsDeleted = 0 AND                                         
  TowerId in (SELECT CAST(Item AS Bigint) FROM dbo.SplitString(@ApplicationId, ','))                                  
                                
  -- Updating the Clustering Ticket Validation Table - update the selected application for transaction Id                                
  UPDATE [ML].TRN_ClusteringTicketValidation_Infra SET                                        
  IsSelected = 0,                                        
  ModifiedBy = @CreatedBy,                           
  ModifiedDate = GETDATE()                                        
  WHERE MLTransactionId = @TransactionId AND IsDeleted = 0 AND                     
  TowerId not in (SELECT CAST(Item AS Bigint) FROM dbo.SplitString(@ApplicationId, ','))  
  
      
 UPDATE [ML].TRN_ClusteringTicketValidation_Infra SET                                        
 TicketType= CASE WHEN @IsSignOff=1 THEN 'LT003' ELSE 'LT002' END    
  WHERE MLTransactionId = @TransactionId AND IsDeleted = 0 AND isSelected<>1  AND                                     
  TowerId in (SELECT CAST(Item AS Bigint) FROM dbo.SplitString(@ApplicationId, ','))   
                                  
  UPDATE [ML].TRN_ClusteringTicketValidation_Infra SET                                        
  IsSelected = 1,                                        
  ModifiedBy = @CreatedBy,                   
  Clusterid_desc = Case When Clusterid_desc is null  THEN 0 ELSE Clusterid_desc END,                  
  ClusterID_Resolution = Case When ClusterID_Resolution is null  THEN 0 ELSE ClusterID_Resolution END,                  
  ModifiedDate = GETDATE()                                        
  WHERE MLTransactionId = @TransactionId AND IsDeleted = 0 AND                                         
  TowerId in (SELECT CAST(Item AS Bigint) FROM dbo.SplitString(@ApplicationId, ','))       
 
    
              
             
 END                                        
                                        
 -- Logic to update the Sceen Id for the Transaction                                        
  UPDATE ML.TRN_MLTransaction SET                                        
  ScreenId = 4,                                              
  ModifiedBy = @CreatedBy,                                              
  ModifiedDate = GETDATE()                                              
  WHERE TransactionId = @TransactionId AND IsDeleted = 0                                        
                                 
   -- Logic to update the status key - in case the selection of application has been changed                              
 IF(@IsAppChanged = 1)                              
 BEGIN                      
 IF(SElect Count(Signoffdate) from ML.TRN_MLTransaction  WHERE TransactionId = @TransactionId AND IsDeleted = 0 AND Signoffdate IS NOT NULL) > 0                
 BEGIN                
 UPDATE ML.ClusteringCLProjects SET                                        
  JobStatusKey = NULL                     
  WHERE TransactionId = @TransactionId AND IsDeleted = 0      
          
 IF(@IsApp = 1)                    
 BEGIN      
    
    
  UPDATE [ML].TRN_ClusteringTicketValidation_App SET             
  TicketType =            
  CASE WHEN (TicketType = 'LT001' AND     
  ((Clusterid_desc IS NULL AND Clusterid_resolution IS NULL) OR (Clusterid_desc =0 AND Clusterid_resolution =0))    
  ) THEN            
  'LT003'            
  ELSE            
  TicketType            
  END,                                 
  ModifiedBy = @CreatedBy,                  
  ModifiedDate = GETDATE()                                        
  WHERE MLTransactionId = @TransactionId AND IsDeleted = 0 AND  IsSelected =1                                      
  AND ApplicationId in (SELECT CAST(Item AS Bigint) FROM dbo.SplitString(@ApplicationId, ','))                
 END                  
 ELSE                  
 BEGIN                  
  UPDATE [ML].TRN_ClusteringTicketValidation_Infra SET             
  TicketType =            
  CASE WHEN (Clusterid_desc IS NULL OR Clusterid_desc =0 OR TicketType = 'LT001') THEN            
  'LT003'            
  ELSE            
  TicketType            
  END,                                 
  ModifiedBy = @CreatedBy,                
  ModifiedDate = GETDATE()                                        
  WHERE MLTransactionId = @TransactionId AND IsDeleted = 0 AND  (Clusterid_desc IS NULL OR Clusterid_desc =0) AND IsSelected =1                                      
  AND TowerId in (SELECT CAST(Item AS Bigint) FROM dbo.SplitString(@ApplicationId, ','))                   
END          
        
        
 END                
                
  UPDATE ML.TRN_MLTransaction SET                                        
  JobStatusKey = CASE WHEN Signoffdate IS NULL THEN NULL ELSE JobStatusKey END,                          
  --ModelAccuracy = NULL,                          
  ModifiedBy = @CreatedBy,                                              
  ModifiedDate = GETDATE()                                              
  WHERE TransactionId = @TransactionId AND IsDeleted = 0 AND JobStatusKey IS NOT NULL                    
                  
                
 END                    
 IF(@IsApp = 1)                    
 BEGIN                  
   SELECT COUNT(ClusterID_Desc) as 'ClusterCount' FROM [ML].TRN_ClusteringTicketValidation_APP (NoLock)                   
   WHERE ClusterID_Desc=0 and IsDeleted=0 and MLTransactionId = @TransactionId                  
 END                  
 ELSE                  
 BEGIN                  
  SELECT COUNT(ClusterID_Desc) as 'ClusterCount' FROM [ML].TRN_ClusteringTicketValidation_Infra (NoLock)                  
  WHERE ClusterID_Desc=0 and IsDeleted=0 and MLTransactionId = @TransactionId                  
 END                  
      COMMIT TRAN                                      
 END TRY                                                
 BEGIN CATCH                        
    ROLLBACK TRAN                    
    DECLARE @ErrorMessage VARCHAR(MAX);                                              
 SELECT @ErrorMessage = ERROR_MESSAGE()                                              
                                            
 EXEC AVL_InsertError '[ML].[UpdatePreRequisiteDetails]', @ErrorMessage, 0,0                                              
 END CATCH;                                                
                                                
 SET NOCOUNT OFF;                                     
END 