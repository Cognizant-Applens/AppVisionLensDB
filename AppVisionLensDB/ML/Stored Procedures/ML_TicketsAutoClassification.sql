-- =============================================      
-- Author:  saranya    
-- Create date: <Create Date,,>      
-- Description: <Description,,>      
-- =============================================      
CREATE PROCEDURE [ML].[ML_TicketsAutoClassification]       
 -- Add the parameters for the stored procedure here      
 @GetTickets [ML].[TVP_TicketsAutoClassification] READONLY      
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      
      
    -- Insert statements for procedure here      
       
 BEGIN TRY      
  UPDATE  TAC SET TAC.[AssignmentGroupId]=TK.[AssignmentGroupId],      
     TAC.[Category]=TK.[Category],      
     TAC.[CauseCodeMapID]=TK.[CausecodeId],      
     TAC.[Comments]=TK.[Comments],      
     TAC.[FlexField1]=TK.[Flex Field (1)],      
     TAC.[FlexField2]=TK.[Flex Field (2)],      
     TAC.[FlexField3]=TK.[Flex Field (3)],      
     TAC.[FlexField4]=TK.[Flex Field (4)],      
     TAC.[KEDBAvailableIndicatorMapID]=TK.[KEDB Available Indicator] ,      
     TAC.[RelatedTickets]=TK.[Related Tickets],      
     TAC.[ReleaseTypeMapID]=TK.[Release Type],      
     TAC.[ResolutionCodeMapID]=TK.[ResolutionCodeId],      
     TAC.[ResolutionRemarks]=TK.[Resolution Remarks],      
     TAC.[TicketDescription]=TK.[TicketDescription],      
     TAC.[TicketSourceMapID]=TK.[TicketsourceId],      
     TAC.[TicketSummary]=TK.[Ticket Summary],      
     TAC.[TicketTypeMapID]=TK.[Ticket Type Id],
     TAC.ModifiedDate=GETDATE()       
   FROM [ML].[TicketsforAutoClassification] AS TAC,@GetTickets AS TK      
  WHERE TAC.[BatchProcessId]=TK.[BatchProcessId]   AND TAC.[TicketId]=TK.TicketId    
  
  --Update ModifiedDate in Batchprocess table
  UPDATE AC set AC.ModifiedDate=GETDATE() FROM [ML].[AutoClassificationBatchProcess] AC, @GetTickets AS TK WHERE AC.BatchProcessId=TK.BatchProcessId
  
 END TRY      
         
 BEGIN CATCH        
 DECLARE @ErrorMessage VARCHAR(MAX);         
        
   SELECT @ErrorMessage = Error_message()         
           
   --INSERT Error             
   EXEC Avl_inserterror         
   '[ML].[TicketsforAutoClassification]',         
   @ErrorMessage,         
   '',         
   0         
  END CATCH        
END
