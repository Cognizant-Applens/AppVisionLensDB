                        
CREATE PROCEDURE [ML].[UpdateCLDecryptedTickets]                          
 @JsonTicketDetails Nvarchar(MAX),        
 @IsApp int,        
 @UserId nvarchar(50) ='System'                       
AS                        
BEGIN                        
BEGIN TRY                        
SET NOCOUNT ON;                        
                                
  SELECT * INTO #tmpDescriptionValues  from (                   
 SELECT ProjectId,[TicketId] TicketID,[DecryptedTicketDescription] DescriptionText,[DecryptedSummaryDescription] SummaryText                      
 FROM OPENJSON(@JsonTicketDetails)                        
  WITH (         
   [ProjectId] bigint '$.ProjectId',        
   [TicketId] nvarchar(max) '$.TicketId',                        
   [DecryptedTicketDescription] nvarchar(max) '$.DecryptedTicketDescription' ,          
   [DecryptedSummaryDescription] nvarchar(max) '$.DecryptedSummaryDescription'           
    )T  ) A                
        
IF @IsApp =1  
BEGIN  
 UPDATE TV SET TV.DescriptionText = CASE WHEN DV.DescriptionText = ' ' THEN NULL ELSE DV.DescriptionText END,           
 TV.SummaryText = CASE WHEN DV.SummaryText = ' ' THEN NULL ELSE DV.SummaryText END,         
    TV.ModifiedBy = @UserID,                          
    TV.ModifiedDate = GETDATE()                          
 FROM ML.TRN_ClusteringTicketValidation_App TV                          
 JOIN #tmpDescriptionValues(NOLOCK) DV                          
  ON DV.ProjectId = TV.ProjectId                          
  AND DV.TicketID = TV.TicketID                         
  where TV.isdeleted = 0    
  END  
  ELSE  
  BEGIN  
  UPDATE TV SET TV.DescriptionText = CASE WHEN DV.DescriptionText = ' ' THEN NULL ELSE DV.DescriptionText END,           
 TV.SummaryText = CASE WHEN DV.SummaryText = ' ' THEN NULL ELSE DV.SummaryText END,         
    TV.ModifiedBy = @UserID,                          
    TV.ModifiedDate = GETDATE()                          
 FROM ML.TRN_ClusteringTicketValidation_Infra TV                          
 JOIN #tmpDescriptionValues(NOLOCK) DV                          
  ON DV.ProjectId = TV.ProjectId                          
  AND DV.TicketID = TV.TicketID                         
  where TV.isdeleted = 0    
  END  
                        
 -- SET @Result = 1                          
 --SELECT @Result AS Result                          
 DROP TABLE #tmpDescriptionValues                  
 END TRY                            
BEGIN CATCH                            
                          
  DECLARE @ErrorMessage VARCHAR(MAX);                          
                          
  SELECT @ErrorMessage = ERROR_MESSAGE()                               
  --INSERT Error                              
  EXEC AVL_InsertError '[ML].[UpdateCLDecryptedTickets]', @ErrorMessage, '',0                          
                            
 END CATCH                            
                          
END