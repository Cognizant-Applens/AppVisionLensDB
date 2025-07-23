
-- =============================================
-- Author:		Priya dharshini D
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [RLE].[LP_GetFavouriteModules] '674078'
CREATE PROCEDURE [RLE].[LP_GetFavouriteModules]
(
@Employeeid NVARCHAR(50)
)
AS
BEGIN

SELECT ModuleId,
CASE WHEN IsDeleted = 0 THEN 1 ELSE 0 END AS IsActive 
FROM RLE.LP_FavouriteModules (NOLOCK) WHERE Employeeid =@Employeeid
AND ModuleId NOT  in (40,41) 
UNION
SELECT ModuleId,
CASE WHEN IsDeleted = 0 THEN 1 ELSE 0 END AS IsActive 
FROM RLE.LP_FavouriteModules (NOLOCK) WHERE Employeeid = @Employeeid
AND ModuleId  in (40,41) AND IsDeleted = 0
END
