CREATE TYPE [RLE].[AddEditPpAccessDetails] AS TABLE (
    [RoleKey]      NVARCHAR (6)  NOT NULL,
    [Group]        NCHAR (100)   NOT NULL,
    [EsaProjectId] NVARCHAR (30) NOT NULL,
    [IsAdd]        BIT           NOT NULL);

