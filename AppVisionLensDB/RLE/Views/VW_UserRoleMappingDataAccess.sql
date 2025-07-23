CREATE VIEW  [RLE].[VW_UserRoleMappingDataAccess] AS
select URM.AssociateId, URM.ApplensRoleID,URDA.ProjectID from RLE.UserRoleMapping as URM
inner join RLE.UserRoleDataAccess as URDA on URDA.RoleMappingId=URM.RoleMappingId
where URM.IsDeleted=0 and URDA.IsDeleted=0