/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/



CREATE PROCEDURE [PP].[SaveProjectPercentage] --'10337'
@ProjectID BIGINT,
@Percentage BIGINT,
@EmployeeID NVARCHAR(50)
AS 
  BEGIN 
	BEGIN TRY 
		SET NOCOUNT ON;
			
IF NOT EXISTS(SELECT TOP 1 1 FROM PP.ProjectProfilingTileProgress WHERE ProjectID = @ProjectID and TileID = 1)
 BEGIN
		INSERT INTO PP.ProjectProfilingTileProgress(ProjectID,TileID,TileProgressPercentage,IsDeleted,CreatedBy,CreatedDateTime)
		VALUES(@ProjectID,1,@Percentage,0,@EmployeeID,GETDATE())
 END

ELSE
		UPDATE PP.ProjectProfilingTileProgress SET TileProgressPercentage=@Percentage WHERE ProjectID=@ProjectID AND TileID = 1

    END TRY 

    BEGIN CATCH 
        DECLARE @ErrorMessage VARCHAR(MAX); 
        SELECT @ErrorMessage = ERROR_MESSAGE() 
        --INSERT Error     
        EXEC AVL_INSERTERROR  'PP.SaveProjectPercentage', @ErrorMessage,  0, 
        0 
    END CATCH 
  END
