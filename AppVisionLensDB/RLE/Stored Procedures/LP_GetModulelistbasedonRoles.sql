-- =============================================
-- Author:		Shobana
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC RLE.LP_GetModulelistbasedonRoles '1,2'
CREATE PROCEDURE [RLE].[LP_GetModulelistbasedonRoles] 
	-- Add the parameters for the stored procedure here
 
AS
BEGIN
	SELECT DISTINCT ModuleId,ApplensRoleId
	FROM RLE.LP_RoleModuleMapping(NOLOCK) WHERE 
	IsDeleted = 0
END