CREATE TABLE [ADM].[MAP_Theme] (
    [ThemeMapId]       BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectThemeName] NVARCHAR (200) NOT NULL,
    [ProjectId]        BIGINT         NULL,
    [IsDeleted]        BIT            NOT NULL,
    [IsDefault]        CHAR (10)      NULL,
    [CreatedBy]        NVARCHAR (50)  NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [ModifiedBy]       NVARCHAR (50)  NULL,
    [ModifiedDate]     DATETIME       NULL,
    CONSTRAINT [PK_MAP_Theme_ThemeMapId] PRIMARY KEY CLUSTERED ([ThemeMapId] ASC),
    CONSTRAINT [FK_MAP_Theme_ProjectId] FOREIGN KEY ([ProjectId]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

