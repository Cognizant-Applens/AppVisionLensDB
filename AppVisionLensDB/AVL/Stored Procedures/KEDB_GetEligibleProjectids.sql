

CREATE PROCEDURE [AVL].[KEDB_GetEligibleProjectids]  --'140014,90402,27984,7826'
@ProjectIDs nVarchar(Max) = null
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
    
     select PPT.ProjectID from pp.ProjectProfilingTileProgress PPT (NoLock) 
	  where PPT.ProjectId In ( select item from dbo.Split(@ProjectIDs,',')) and PPT.TileProgressPercentage=100 and PPT.IsDeleted=0 and
	 PPT.TileID=10
	
End Try


   BEGIN CATCH  

		DECLARE @ErrorMessage VARCHAR(MAX);

		SELECT @ErrorMessage = ERROR_MESSAGE()

		--INSERT Error    
		EXEC AVL_InsertError 'AVL.KEDB_GetEligibleProjectids', @ErrorMessage, 'sys',0
		
	END CATCH   

   
END
