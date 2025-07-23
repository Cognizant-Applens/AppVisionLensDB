  
-- =============================================    
-- Author:  699158    
-- Create date: 17/09/2022    
-- Description: Values for python    
-- =============================================    
CREATE PROCEDURE ML.UpdateTicketEncDetailsForPython     
 @JsonTicketDetails Nvarchar(MAX),          
 @TransactionId bigint,          
 @UserId nvarchar(50)          
AS          
BEGIN          
BEGIN TRY          
SET NOCOUNT ON;          
CREATE TABLE #DescriptionValues            
 (         
  [TicketID] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,            
  [DescriptionText] [varchar](max) NULL,      
  [SummaryText] [varchar](max) NULL      
 )            
  INSERT INTO #DescriptionValues([TicketID], [DescriptionText],[SummaryText])          
 SELECT [TicketId],[DecryptedTicketDescription],[DecryptedSummaryDescription]          
 FROM OPENJSON(@JsonTicketDetails)          
  WITH (          
          
   [TicketId] nvarchar(max) '$.TicketId',          
   [DecryptedTicketDescription] nvarchar(max) '$.DecryptedTicketDescription' ,      
   DecryptedSummaryDescription nvarchar(max) '$.DecryptedSummaryDescription'       
    )T          
      
   IF(SELECT COUNT(*) FROM ML.TRN_MLTRANSACTION(NOLOCK) WHERE TRANSACTIONID =@TransactionId AND SupportTypeId=1) > 0    
   BEGIN    
  UPDATE TV SET TV.DescriptionText = DV.DescriptionText,   TV.SummaryText = DV.[SummaryText],          
  TV.ModifiedBy = @UserID,            
  TV.ModifiedDate = GETDATE()            
  FROM ML.TRN_ClusteringTicketValidation_App TV            
  JOIN #DescriptionValues(NOLOCK) DV            
   ON  DV.TicketID = TV.TicketID           
   where TV.isdeleted = 0  and TV.MLTransactionId =@TransactionId        
      
  END    
  ELSE    
  BEGIN    
   UPDATE TV SET TV.DescriptionText = DV.DescriptionText,  TV.SummaryText = DV.[SummaryText],          
  TV.ModifiedBy = @UserID,            
  TV.ModifiedDate = GETDATE()            
  FROM ML.TRN_ClusteringTicketValidation_Infra TV            
  JOIN #DescriptionValues(NOLOCK) DV            
   ON  DV.TicketID = TV.TicketID           
   where TV.isdeleted = 0  and TV.MLTransactionId =@TransactionId     
      
     
  END    
   END TRY    
   BEGIN CATCH    
    DECLARE @ErrorMessage VARCHAR(MAX);    
    SELECT @ErrorMessage = ERROR_MESSAGE()                               
  --INSERT Error                              
 EXEC AVL_InsertError '[ML].[UpdateTicketEncDetailsForPython] ', @ErrorMessage, '',0     
   END CATCH    
END
