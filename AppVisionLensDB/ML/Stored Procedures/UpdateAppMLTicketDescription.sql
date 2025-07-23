
                  
CREATE PROCEDURE [ML].[UpdateAppMLTicketDescription]                    
 @JsonTicketDetails Nvarchar(MAX),                  
 @TransactionId bigint,                  
 @UserId nvarchar(50)                  
AS                  
BEGIN                  
BEGIN TRY                  
SET NOCOUNT ON;                  
                          
  SELECT * INTO #tmpDescriptionValues  from (             
 SELECT @TransactionId MLTransactionId,[TicketId] TicketID,[DecryptedTicketDescription] DescriptionText,[DecryptedSummaryDescription] SummaryText                
 FROM OPENJSON(@JsonTicketDetails)                  
  WITH (                
   [TicketId] nvarchar(max) '$.TicketId',                  
   [DecryptedTicketDescription] nvarchar(max) '$.DecryptedTicketDescription' ,    
   [DecryptedSummaryDescription] nvarchar(max) '$.DecryptedSummaryDescription'     
    )T  ) A          
                  
 UPDATE TV SET TV.DescriptionText = CASE WHEN DV.DescriptionText = ' ' THEN NULL ELSE DV.DescriptionText END,    
 TV.SummaryText = CASE WHEN DV.SummaryText = ' ' THEN NULL ELSE DV.SummaryText END,   
    TV.ModifiedBy = @UserID,                    
    TV.ModifiedDate = GETDATE()                    
 FROM ML.TRN_ClusteringTicketValidation_App TV                    
 JOIN #tmpDescriptionValues(NOLOCK) DV                    
  ON DV.MLTransactionId = TV.MLTransactionId                    
  AND DV.TicketID = TV.TicketID                   
  where TV.isdeleted = 0      
                  
 -- SET @Result = 1                    
 --SELECT @Result AS Result                    
 DROP TABLE #tmpDescriptionValues            
 END TRY                      
BEGIN CATCH                      
                    
  DECLARE @ErrorMessage VARCHAR(MAX);                    
                    
  SELECT @ErrorMessage = ERROR_MESSAGE()                         
  --INSERT Error                        
  EXEC AVL_InsertError '[ML].[UpdateMLTicketDescription] ', @ErrorMessage, '',0                    
                      
 END CATCH                      
                    
END
