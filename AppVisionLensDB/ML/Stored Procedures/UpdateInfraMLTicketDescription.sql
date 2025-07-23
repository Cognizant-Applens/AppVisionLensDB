      
CREATE PROCEDURE [ML].[UpdateInfraMLTicketDescription]        
 @JsonTicketDetails Nvarchar(MAX),      
 @TransactionId bigint,      
 @UserId nvarchar(50)      
AS      
BEGIN      
BEGIN TRY      
SET NOCOUNT ON;      
CREATE TABLE #DescriptionValues        
 (         
  [MLTransactionId] BIGINT,         
  [TicketID] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,        
  [DescriptionText] [varchar](max) NULL,  
  [SummaryText] [varchar](max) NULL  
 )        
  INSERT INTO #DescriptionValues([MLTransactionId], [TicketID], [DescriptionText],[SummaryText])      
 SELECT @TransactionId,[TicketId],[DecryptedTicketDescription],[DecryptedSummaryDescription]      
 FROM OPENJSON(@JsonTicketDetails)      
  WITH (      
      
   [TicketId] nvarchar(max) '$.TicketId',      
   [DecryptedTicketDescription] nvarchar(max) '$.DecryptedTicketDescription' ,  
   DecryptedSummaryDescription nvarchar(max) '$.DecryptedSummaryDescription'   
    )T      
      
 UPDATE TV SET TV.DescriptionText = DV.DescriptionText,        
    TV.ModifiedBy = @UserID,        
    TV.ModifiedDate = GETDATE()        
 FROM ML.TRN_ClusteringTicketValidation_Infra TV        
 JOIN #DescriptionValues(NOLOCK) DV        
  ON DV.MLTransactionId = TV.MLTransactionId        
  AND DV.TicketID = TV.TicketID       
  where TV.isdeleted = 0      
  
    UPDATE TV SET TV.SummaryText = DV.[SummaryText],        
    TV.ModifiedBy = @UserID,        
    TV.ModifiedDate = GETDATE()        
 FROM ML.TRN_ClusteringTicketValidation_Infra TV        
 JOIN #DescriptionValues(NOLOCK) DV        
  ON DV.MLTransactionId = TV.MLTransactionId        
  AND DV.TicketID = TV.TicketID       
  where TV.isdeleted = 0      
      
 -- SET @Result = 1        
 --SELECT @Result AS Result        
      
 END TRY          
BEGIN CATCH          
        
  DECLARE @ErrorMessage VARCHAR(MAX);        
        
  SELECT @ErrorMessage = ERROR_MESSAGE()        
  --INSERT Error            
  EXEC AVL_InsertError '[ML].[UpdateMLTicketDescription] ', @ErrorMessage, '',0        
          
 END CATCH          
        
END
