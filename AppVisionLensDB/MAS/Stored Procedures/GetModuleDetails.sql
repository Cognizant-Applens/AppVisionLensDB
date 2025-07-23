CREATE PROCEDURE [MAS].[GetModuleDetails]
AS
BEGIN
		SELECT ID AS ModuleID
			,ModuleName
			,Description
			,ProjectScopeConfig
			,ALMToolConfig
			,ShowInUI
		FROM MAS.ApplensModule
		WHERE IsDeleted = 0
END