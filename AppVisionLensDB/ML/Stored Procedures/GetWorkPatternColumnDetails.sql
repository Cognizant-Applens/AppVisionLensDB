
CREATE PROCEDURE [ML].[GetWorkPatternColumnDetails]--105188
(
@ProjectID BIGINT  --ProjectID
)
AS
BEGIN

	BEGIN TRY
		BEGIN TRAN
		SET NOCOUNT ON;			
			DECLARE @TicketIDColumnName NVARCHAR(100)

			SET @TicketIDColumnName=(SELECT ProjectColumn from avl.ITSM_PRJ_SSISColumnMapping (NOLOCK) 
			WHERE ProjectID=@ProjectID AND  ServiceDartColumn = 'Ticket ID')

			SELECT ISNULL(@TicketIDColumnName,'Ticket ID') AS TicketID,
			'Desc_Base_WorkPattern'AS TicketDescriptionBasePattern,
			'Desc_Sub_WorkPattern' AS TicketDescriptionSubPattern,
			'Res_Base_WorkPattern' AS ResolutionRemarksBasePattern,
			'Res_Sub_WorkPattern' AS ResolutionRemarksSubPattern	
			
        SET NOCOUNT OFF
		COMMIT TRAN
		END TRY
		BEGIN CATCH
		
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		INSERT INTO AVL.Errors VALUES(0,'ML.GetWorkPatternColumnDetails',@ErrorMessage,'system',GETDATE())

		ROLLBACK TRAN	
		              
   END CATCH
  
END
