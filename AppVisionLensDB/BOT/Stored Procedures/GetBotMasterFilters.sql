CREATE PROC [BOT].[GetBotMasterFilters]  @Flag int
AS
BEGIN
BEGIN TRY
		BEGIN TRAN
		SET NOCOUNT ON;	
IF(@Flag=1)
BEGIN
select Id AS BotTypeID, type AS BotTypeName from bot.BOTType (NOLOCK) order by BotTypeName asc
END

IF(@Flag=2)
BEGIN
select ID AS TargetApplicationID,TargetApplicationName as TargetApplicationName from bot.TargetApplication (NOLOCK) order by TargetApplicationName asc
END
IF(@Flag=3)
BEGIN
select PrimaryTechnologyID AS TechnologyID,PrimaryTechnologyName AS TechnologyName from avl.APP_MAS_PrimaryTechnology (NOLOCK) order by PrimaryTechnologyName asc;
END
SET NOCOUNT OFF;
COMMIT TRAN
END TRY
BEGIN CATCH	

		SELECT ERROR_MESSAGE() AS Result

		DECLARE @ErrorMessage VARCHAR(MAX);
		SELECT @ErrorMessage = ERROR_MESSAGE()
		INSERT INTO AVL.Errors VALUES(0,'[bot].[GetBotMasterFilters]',@ErrorMessage,'system',GETDATE())

		ROLLBACK TRAN	
		              
END CATCH

END
