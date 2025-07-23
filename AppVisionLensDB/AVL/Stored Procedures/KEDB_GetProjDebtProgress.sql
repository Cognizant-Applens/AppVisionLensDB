CREATE PROCEDURE [AVL].[KEDB_GetProjDebtProgress]

@ProjectID int

AS

BEGIN

SET NOCOUNT ON;

BEGIN TRY

    select TileProgressPercentage from pp.ProjectProfilingTileProgress (NoLock) where ProjectId = @ProjectID and tileId = 10

END TRY

 BEGIN CATCH  



        DECLARE @ErrorMessage VARCHAR(MAX);



        SELECT @ErrorMessage = ERROR_MESSAGE()



        --INSERT Error    

        EXEC AVL_InsertError 'AVL.KEDB_GetProjDebtProgress', @ErrorMessage, @ProjectID,0

        

    END CATCH   

END

