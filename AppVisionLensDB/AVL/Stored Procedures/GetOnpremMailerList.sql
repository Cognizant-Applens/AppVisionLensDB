CREATE PROCEDURE [AVL].[GetOnpremMailerList]
AS
BEGIN
BEGIN TRY

SELECT EmployeeEmail,IsCC FROM dbo.Onprem_JobMail where IsActive = 1;

END TRY
BEGIN CATCH
DECLARE @Message VARCHAR(MAX);
DECLARE @ErrorSource VARCHAR(MAX);

SELECT @Message = ERROR_MESSAGE()
select @ErrorSource = ERROR_STATE()
EXEC dbo.AVL_InsertError '[AVL].[GetOnpremMailerList]',@ErrorSource,@Message,0
END CATCH
END
