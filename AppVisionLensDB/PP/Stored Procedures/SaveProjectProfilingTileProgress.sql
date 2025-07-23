/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [PP].[SaveProjectProfilingTileProgress]
(
	@ProjectID		BIGINT,   
	@TileID			SMALLINT,
	@TilePercentage INT,
	@CreatedBy		VARCHAR(100) NULL
)
AS
BEGIN
SET NOCOUNT ON
BEGIN TRY

	IF EXISTS (SELECT TOP 1 1 FROM PP.ProjectProfilingTileProgress 
				WHERE ProjectId = @ProjectID AND TileID = @TileID AND IsDeleted = 0)
	BEGIN

		UPDATE PP.ProjectProfilingTileProgress 
		SET TileProgressPercentage  = @TilePercentage,
			ModifiedBy				= @CreatedBy,
			ModifiedDateTime		= GETDATE()
		WHERE ProjectID = @ProjectID AND TileID = @TileID AND IsDeleted = 0

	END
	ELSE
	BEGIN

		INSERT INTO PP.ProjectProfilingTileProgress 
		(
			ProjectID, TileID, TileProgressPercentage, IsDeleted, CreatedBy, CreatedDateTime,
			ModifiedBy, ModifiedDateTime
		) 
		VALUES (@ProjectID, @TileID, @TilePercentage, 0, @CreatedBy, GETDATE(), NULL, NULL)

	END

END TRY
BEGIN CATCH
	     
	DECLARE @ErrorMessage VARCHAR(MAX);
	SELECT @ErrorMessage = ERROR_MESSAGE()
		
	--EXEC AVL_InsertError '[PP].[SaveProjectProfilingTileProgress]', @ErrorMessage, 0 , ''
	  EXEC AVL_InsertError '[PP].[SaveProjectProfilingTileProgress]',     
@ErrorMessage, @CreatedBy ,@ProjectID 
END CATCH

SET NOCOUNT OFF

END
