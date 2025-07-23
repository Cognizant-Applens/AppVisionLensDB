
CREATE PROCEDURE [ML].[SaveOutComeDetails]                  
-- Add the parameters for the stored procedure here                 
 @OutComeID int,                  
 @MLTransactionId int,                  
 @MinimumPoint int,                  
 @Threshold int,                  
 @ThresholdRange int,                  
 @Level2Id int,                  
 @CreatedBy NVarchar(50),      
 @IsEncrypt BIT,    
 @isRegenerative BIT    
  AS                  
  BEGIN                  
  BEGIN TRY        
  BEGIN TRAN        
          
UPDATE A SET A.TICKETDESCRIPTION=B.TICKETDESCRIPTION,                                                                               
A.TicketSummary= B.TicketSummary,                                                                                   
A.DebtClassificationID= case when isnull(B.[DebtClassificationMapID], 0)<> 0 then B.[DebtClassificationMapID] else A.DebtClassificationID  end,                                                           
A.AvoidableFlagID= case when isnull(B.AvoidableFlag, 0)<> 0 then B.AvoidableFlag else A.AvoidableFlagId end,                                                                    
A.ResidualDebtID=case when isnull(B.ResidualDebtMapID, 0)<> 0 then B.ResidualDebtMapID else A.ResidualDebtID end,                                                                      
A.CauseCodeID=B.[CauseCodeMapID],                                                                      
A.ResolutionCodeID=B.[ResolutionCodeMapID]        
  FROM ML.TRN_ClusteringTicketValidation_App A        
  INNER JOIN ML.TRN_MLTRANSACTION TR ON  A.MLTRANSACTIONID=TR.TRANSACTIONID        
  INNER JOIN [AVL].[TK_TRN_TICKETDETAIL] B ON A.TICKETID=B.TICKETID         
  AND TR.PROJECTID=B.PROJECTID AND A.ISDELETED=0 AND B.ISDELETED=0 AND TR.ISDELETED=0   
  WHERE TR.TRANSACTIONID = @MLTransactionId   
        
  -- SET NOCOUNT ON added to prevent extra result sets from                  
  -- interfering with SELECT statements. select * from [ML].[TRN_MLTransaction]                
  DECLARE @outcomeids int;               
  set @outcomeids = (select TOP 1 outcomeID from [ML].[TRN_OutCome]  where MLTransactionId = @MLTransactionId AND IsDeleted = 0)          
  SET NOCOUNT ON;                  
                  
                  
-- Insert statements for procedure here                  
--select * from [ML].[TRN_OutCome]                  
  IF(@outcomeids > 0)                  
  BEGIN                  
   UPDATE [ML].[TRN_OutCome]                  
   SET                  
   [MLTransactionId] = @MLTransactionId,                  
   [MinimumPoint] = @MinimumPoint,                  
   [Threshold] = @Threshold,                  
   [ThresholdRange] = @ThresholdRange,                  
   [Level2Id] = @Level2Id,                  
   [CreatedBy] = @CreatedBy                  
   WHERE [OutComeId] = @outcomeids                 
  select @OutcomeID                 
  END                  
  ELSE                  
  BEGIN                  
   INSERT INTO [ML].[TRN_OutCome]                  
   ([MLTransactionId]                  
   ,[MinimumPoint]                  
   ,[Threshold]                  
   ,[ThresholdRange]                  
   ,[Level2Id]                  
   ,[IsDeleted]                  
   ,[CreatedBy]                  
   ,[CreatedDate]                  
   ,[ModifiedBy]                  
   ,[ModifiedDate])                  
   VALUES                  
   (@MLTransactionId,@MinimumPoint,@Threshold,@ThresholdRange,@Level2Id,0,@CreatedBy,GETDATE(),NULL,NULL)                  
  SET @OutcomeID = SCOPE_IDENTITY();                  
  select @OutcomeID                  
  END                  
 if @isRegenerative=1    
  BEGIN    
 UPDATE [ML].[ClusteringCLProjects] set JobStatusKey = 'SK001',IsRegenerate = 1,RegeneratedDate = GETDATE() where TransactionId = @MLTransactionId;    
  END     
  ELSE     
  BEGIN    
 UPDATE [ML].[TRN_MLTransaction] set JobStatusKey = 'SK001' where TransactionId = @MLTransactionId;     
  END        
      
IF @IsEncrypt = 0      
BEGIN      
      
UPDATE ML.TRN_ClusteringTicketValidation_App SET DescriptionText=TicketDescription, SummaryText=TicketSummary      
WHERE MLTRANSACTIONID =@MLTransactionId AND IsDeleted=0 AND (ISNULL(ClusterId_desc,0) =0 OR ISNULL(ClusterID_Resolution,0) =0)      
      
UPDATE ML.TRN_ClusteringTicketValidation_Infra SET DescriptionText=TicketDescription, SummaryText=TicketSummary      
WHERE MLTRANSACTIONID =@MLTransactionId AND IsDeleted=0 AND (ISNULL(ClusterId_desc,0) =0 OR ISNULL(ClusterID_Resolution,0) =0)      
END      
          
        
        
SET NOCOUNT OFF            
COMMIT TRAN        
END TRY                  
BEGIN CATCH             
ROLLBACK TRAN        
DECLARE @ErrorMessage VARCHAR(MAX);                  
SELECT @ErrorMessage = ERROR_MESSAGE()                  
--INSERT Error                  
EXEC AVL_InsertError '[ML].[SaveOutComeDetails]', @ErrorMessage,0,0                  
END CATCH                  
END