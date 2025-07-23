
CREATE PROCEDURE [ML].[SaveWorkPatternHeaderDetails]
(
	@ID BIGINT, --ProjectID
	@TicketDescBasePatt NVARCHAR(250),
	@TicketDescSubPatt NVARCHAR(250),
	@ResolRemarksBasePatt NVARCHAR(250),
	@ResolRemarksSubPatt NVARCHAR(250),
	@UserID NVARCHAR(10)
)
AS
BEGIN
	 BEGIN TRY
		BEGIN TRAN
		SET NOCOUNT ON;
		DECLARE @Result BIT;
		IF NOT EXISTS(SELECT 1 FROM [ML].[WorkPatternConfiguration](NOLOCK) WHERE ProjectID = @ID AND IsDeleted = 0)
		BEGIN
			INSERT INTO [ML].[WorkPatternConfiguration] VALUES(@ID,@TicketDescBasePatt,@TicketDescSubPatt,@ResolRemarksBasePatt
			,@ResolRemarksSubPatt,0,@UserID,GETDATE(),NULL,NULL)
		END
		ELSE
		BEGIN
			UPDATE [ML].[WorkPatternConfiguration] SET TicketDescriptionBasePattern = @TicketDescBasePatt
			,TicketDescriptionSubPattern = @TicketDescSubPatt
			,ResolutionRemarksBasePattern = @ResolRemarksBasePatt
			,ResolutionRemarksSubPattern = @ResolRemarksSubPatt
			,ModifiedBy = @UserID
			,ModifiedDate = GETDATE()
			WHERE ProjectID = @ID AND IsDeleted = 0
		END
	   SET @Result = 1
	   SELECT @Result AS Result
	   SET NOCOUNT OFF
   COMMIT TRAN
	END TRY
	BEGIN CATCH
	 SET @Result = 0
		SELECT @Result AS Result
		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		INSERT INTO AVL.Errors VALUES(0,'ML.SaveWorkPatternHeaderDetails',@ErrorMessage,'system',GETDATE())

		ROLLBACK TRAN	
		              
   END CATCH
END
