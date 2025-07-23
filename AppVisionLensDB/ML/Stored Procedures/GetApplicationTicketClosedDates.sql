CREATE PROCEDURE [ML].[GetApplicationTicketClosedDates]                                  
@ProjectId BIGINT      
AS    
BEGIN                                             
BEGIN TRY                       
                                                              
select min(ClosedDate) as fromDate, max(ClosedDate) as toDate from [AVL].[TK_TRN_TicketDetail] Where ProjectID=@ProjectId                        
                                        
END TRY                                            
BEGIN CATCH                                            
                                                         
  DECLARE @ErrorMessage VARCHAR(MAX);                                          
  SELECT @ErrorMessage = ERROR_MESSAGE()                                         
                                                   
  EXEC AVL_InsertError '[ML].[GetMLTransactionDetails]', @ErrorMessage, 0,0                                          
                                            
 END CATCH                                             
END