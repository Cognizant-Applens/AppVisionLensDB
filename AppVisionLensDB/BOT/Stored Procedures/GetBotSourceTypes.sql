CREATE PROCEDURE [BOT].[GetBotSourceTypes] 
AS
BEGIN 
  BEGIN TRY 
  SET NOCOUNT ON;

	SELECT DISTINCT source FROM [BOT].[MasterRepository] (NOLOCK) where source is not null

  SET NOCOUNT OFF;
  END TRY
  BEGIN CATCH
	DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()
	--INSERT Error    
	EXEC AVL_InsertError '[BOT].[MasterRepository]', @ErrorMessage, '',''
	RETURN @ErrorMessage
  END CATCH

END