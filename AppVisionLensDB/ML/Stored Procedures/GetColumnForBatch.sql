            
CREATE PROCEDURE ML.GetColumnForBatch               
(@BatchProcessId INT)              
AS              
BEGIN             
BEGIN TRY                  
 SET NOCOUNT ON;               
            
select             
[AssignmentGroupId] 'Assignment Group',            
[Category] ,            
[CauseCodeMapID] 'Cause Code',            
[Comments] ,            
[FlexField1] 'Flex Field (1)' ,            
[FlexField2] 'Flex Field (2)',            
[FlexField3] 'Flex Field (3)',            
[FlexField4] 'Flex Field (4)',            
[KEDBAvailableIndicatorMapID] 'KEDB Available Indicator'  ,            
[RelatedTickets] 'Related Tickets',            
[ReleaseTypeMapID] 'Release Type',            
[ResolutionCodeMapID] 'Resolution Code',            
[ResolutionRemarks] 'Resolution Remarks',            
[TicketDescription] 'Ticket Description',            
[TicketSourceMapID] 'Ticket Source',            
[TicketSummary] 'Ticket Summary',            
[TicketTypeMapID] 'Ticket Type',            
BatchProcessId,            
TicketId,      
SupportType      
from  ML.TicketsforAutoClassification where BatchProcessId=@BatchProcessId AND IsDeleted=0            
                  
END TRY                  
BEGIN CATCH                  
DECLARE @ErrorMessage VARCHAR(MAX);                  
                  
  SELECT @ErrorMessage = ERROR_MESSAGE()                  
                  
  --INSERT Error                      
  EXEC AVL_InsertError '[dbo].[GetColumnForBatch]', @ErrorMessage ,''                  
END CATCH                    
END
