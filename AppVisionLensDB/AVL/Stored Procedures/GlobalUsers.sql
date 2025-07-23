CREATE PROC [AVL].[GlobalUsers] 
AS
BEGIN

SELECT DISTINCT A.ApplensRoleID,reverse(stuff(reverse(AVL.GlobalRoles(A.ApplensRoleID)), 1, 1, '')) AS Users
FROM RLE.UserRoleMapping(NOLOCK) A 
WHERE A.GroupId=2 and A.ApplensRoleID IN(16,19,20,21,24,26,33,35,37,38,39,51,60) and A.IsDeleted=0 

END