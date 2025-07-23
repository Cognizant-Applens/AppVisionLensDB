CREATE TYPE [PP].[TVP_ProjectDetails] AS TABLE (
    [ParentID]     BIGINT         NULL,
    [ID]           BIGINT         NULL,
    [Name]         NVARCHAR (MAX) NULL,
    [LevelID]      INT            NULL,
    [RoleID]       INT            NULL,
    [EsaProjectID] BIGINT         NULL);

