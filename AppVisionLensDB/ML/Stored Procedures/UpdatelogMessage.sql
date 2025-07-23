CREATE PROCEDURE [ML].[UpdatelogMessage] 
@BatchIDApp bigint, 
@BatchIDInfra bigint = null, 
@Message nvarchar(max)

AS
BEGIN
BEGIN TRY

	SET NOCOUNT ON;
	
	update ML.DebtAutoClassificationBatchProcess set  Message = @Message where BatchProcessId = @BatchIDApp

	IF(@BatchIDInfra > 0)
	BEGIN
		update ML.DebtAutoClassificationBatchProcess set  Message = @Message where BatchProcessId = @BatchIDInfra
	END

END TRY
BEGIN CATCH 
DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError '[ML].[UpdatelogMessage]', @ErrorMessage,'job'
END CATCH
END