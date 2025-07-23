
CREATE PROCEDURE [ML].[Updatetickettext] 
@ticketdetails [ML].[TVP_TicketListML]  READONLY

AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	
	update TC set  TC.TicketDescription = TD.TicketDescription, Tc.AdditionalText = TD.AdditionalText from  [ML].[TicketsForClassification] TC
	join @ticketdetails TD on TD.BatchProcessId = TC.BatchProcessId and TD.TicketId = TC.TicketId

END TRY
BEGIN CATCH 
DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[ML].[Updatetickettext]', @ErrorMessage,'job'
END CATCH
END
