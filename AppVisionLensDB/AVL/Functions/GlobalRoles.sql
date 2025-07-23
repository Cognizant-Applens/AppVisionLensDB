CREATE FUNCTION [AVL].[GlobalRoles] (@ApplensRoleId BIGINT)
RETURNS NVARCHAR(MAX) AS
BEGIN
DECLARE @CSV NVARCHAR(MAX);
SELECT @CSV = COALESCE(@CSV + '|', '') + RTrim(LTrim(A.AssociateID)) 
from RLE.UserRoleMapping(NOLOCK) A 
where A.GroupId=2 AND A.ApplensRoleId = @ApplensRoleId AND A.IsDeleted=0
Declare @data nvarchar(max) = @CSV
Declare @finalstring nvarchar(max) = ''
select @finalstring = @finalstring + value + ',' from string_split(@data,',')
GROUP BY value
 
RETURN @finalstring
 
END