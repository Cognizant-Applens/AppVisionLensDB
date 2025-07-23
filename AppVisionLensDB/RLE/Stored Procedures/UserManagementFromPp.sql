/***************************************************************************
*COGNIZANT CONFIDENTIAL AND/OR TRADE SECRET
*Copyright [2018] – [2021] Cognizant. All rights reserved.
*NOTICE: This unpublished material is proprietary to Cognizant and
*its suppliers, if any. The methods, techniques and technical
  concepts herein are considered Cognizant confidential and/or trade secret information. 
  
*This material may be covered by U.S. and/or foreign patents or patent applications. 
*Use, distribution or copying, in whole or in part, is forbidden, except by express written permission of Cognizant.
***************************************************************************/

CREATE PROCEDURE [RLE].[UserManagementFromPp]
@CurrentUserId [nvarchar](50),
@DataSource [nvarchar](10),
@AssociateId [nvarchar](50),
@AccessDetails [RLE].[AddEditPpAccessDetails] READONLY
AS
BEGIN
	SET XACT_ABORT ON;  

	DECLARE @RoleMapping TABLE (
    RoleMappingID bigint,  
    AssociateID NVARCHAR(50),  
    GroupId int,
	ApplensRoleID int); 
	DECLARE @Date DateTime = GETDATE()

	--Project Level Access
	SELECT a.AssociateId, r.ApplensRoleId, g.GroupID, p.ProjectId, (CASE WHEN ad.IsAdd = 1 THEN 0 ELSE 1 END) IsDeleted, 0 IsExists
	into #tempProjectLevelAccess 
	FROM @AccessDetails ad
	JOIN ESA.Associates a on a.AssociateID = @AssociateId and A.IsActive = 1
	JOIN MAS.RLE_Roles r on r.RoleKey = ad.RoleKey and r.IsDeleted = 0
	JOIN MAS.RLE_Groups g on g.GroupName = ad.[Group] and g.IsDeleted = 0
	JOIN AVL.MAS_projectMaster p on p.ESAProjectID = ad.EsaProjectId and p.IsDeleted = 0
	Where r.RoleKey in ('RLE003', 'RLE005')

	UPDATE t SET  IsExists = 1 
	FROM #tempProjectLevelAccess t
	LEFT JOIN RLE.UserRoleMapping rm ON rm.AssociateID = t.AssociateID AND rm.ApplensRoleID = t.ApplensRoleID 
					AND rm.GroupId = t.GroupID AND rm.IsDeleted = 0
	LEFT JOIN RLE.UserRoleDataAccess da ON rm.RoleMappingId = da.RoleMappingId AND da.ProjectId = t.ProjectId AND da.IsDeleted = 0
	Where t.IsDeleted = 0 and da.Id is NOT NULL

	BEGIN TRY
		BEGIN TRANSACTION

		IF EXISTS(SELECT TOP 1 1 FROM #tempProjectLevelAccess WHERE IsDeleted = 0)
		BEGIN
			INSERT INTO RLE.UserRoleMapping (AssociateID, ApplensRoleID, GroupID, Createdby, CreatedDate, DataSource,IsDeleted)
			OUTPUT INSERTED.RoleMappingId, INSERTED.AssociateId, INSERTED.GroupId, INSERTED.ApplensRoleId INTO @RoleMapping
			SELECT DISTINCT t.AssociateID, t.ApplensRoleID, t.GroupID, @CurrentUserId, @Date, @DataSource,0  
			FROM #tempProjectLevelAccess t
			WHERE t.IsDeleted = 0 AND T.IsExists = 0

			INSERT INTO RLE.UserRoleDataAccess (RoleMappingId, AssociateID, ProjectID, Createdby, CreatedDate, DataSource,IsDeleted)
			SELECT DISTINCT rm1.RoleMappingId, t.AssociateID, t.ProjectID, @CurrentUserId, @Date, @DataSource,0  
			FROM #tempProjectLevelAccess t
			JOIN @RoleMapping rm1 ON rm1.AssociateID = t.AssociateID AND rm1.ApplensRoleID = t.ApplensRoleID 
				AND rm1.GroupId = t.GroupID
			WHERE t.IsDeleted = 0 AND T.IsExists = 0
		END

		IF EXISTS(SELECT TOP 1 1 FROM #tempProjectLevelAccess WHERE IsDeleted = 1)
		BEGIN
			UPDATE da SET IsDeleted = 1, ModifiedDate = @Date, ModifiedBy = @CurrentUserId
			FROM RLE.UserRoleDataAccess da
			JOIN RLE.UserRoleMapping rm on rm.RoleMappingID = da.RoleMappingID AND rm.IsDeleted = 0
			JOIN #tempProjectLevelAccess t on rm.AssociateID = t.AssociateID AND rm.ApplensRoleID = t.ApplensRoleID 
				AND rm.GroupId = t.GroupID AND da.ProjectID = t.ProjectId
			Where t.IsDeleted = 1 AND da.IsDeleted = 0

			UPDATE rm SET IsDeleted = 1, ModifiedDate = @Date, ModifiedBy = @CurrentUserId
			FROM RLE.UserRoleMapping rm
			JOIN #tempProjectLevelAccess t on rm.AssociateID = t.AssociateID AND rm.ApplensRoleID = t.ApplensRoleID 
				AND rm.GroupId = t.GroupID 
			Where rm.IsDeleted = 0 AND 
			NOT EXISTS (SELECT 1 FROM RLE.UserRoleDataAccess rm1 
			WHERE rm1.RoleMappingID = rm.RoleMappingID AND rm1.IsDeleted = 0)
		END	
		DROP TABLE #tempProjectLevelAccess
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DROP TABLE #tempProjectLevelAccess
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
