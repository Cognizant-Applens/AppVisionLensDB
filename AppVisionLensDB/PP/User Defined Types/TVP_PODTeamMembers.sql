CREATE TYPE [PP].[TVP_PODTeamMembers] AS TABLE (
    [UserID]   BIGINT         NULL,
    [UserName] NVARCHAR (100) NULL,
    [RoleID]   BIGINT         NULL,
    [RoleName] NVARCHAR (100) NULL,
    [Capacity] DECIMAL (5, 2) NULL);

