/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [RLE].[RefreshUserRoleMappingActiveRecords]
AS
BEGIN
	SET XACT_ABORT ON;  

	SELECT rm.RoleMappingID, da.ID, COALESCE(da.ValidTillDate, rm.ValidTillDate) ValidTillDate into #Temp FROM RLE.UserRoleMapping rm
	LEFT JOIN RLE.UserRoleDataAccess da ON rm.RoleMappingID = da.RoleMappingID AND da.IsDeleted = 0
	WHERE rm.IsDeleted = 0 AND COALESCE(da.DataSource,rm.DataSource) in ('UI', 'PP') 
	AND COALESCE(da.ValidTillDate, rm.ValidTillDate) < CONVERT(date,GETDATE());
	BEGIN TRY
		BEGIN TRANSACTION
			
			UPDATE da SET da.IsDeleted = 1, da.ModifiedBy = 'System', da.ModifiedDate = GETDATE()
			FROM RLE.UserRoleDataAccess da
			JOIN #Temp t ON t.ID = da.ID 
			Where da.IsDeleted = 0 AND da.DataSource in ('UI', 'PP') 

			UPDATE rm SET rm.IsDeleted = 1, rm.ModifiedBy = 'System', rm.ModifiedDate = GETDATE()
			FROM RLE.UserRoleMapping rm
			JOIN #Temp t ON t.RoleMappingID = rm.RoleMappingID
			WHERE rm.IsDeleted = 0 AND rm.DataSource in ('UI', 'PP') AND 
			NOT EXISTS (SELECT 1 FROM RLE.UserRoleDataAccess rm1 
			WHERE rm1.RoleMappingID = rm.RoleMappingID AND rm1.IsDeleted = 0 AND rm1.DataSource in ('UI', 'PP'))

			DROP TABLE #Temp;
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	    DROP TABLE #Temp;
		IF (XACT_STATE()) = -1  
		BEGIN  
			ROLLBACK TRANSACTION;  
		END;  
		IF (XACT_STATE()) = 1  
		BEGIN  
			COMMIT TRANSACTION;     
		END;
	END CATCH
END
