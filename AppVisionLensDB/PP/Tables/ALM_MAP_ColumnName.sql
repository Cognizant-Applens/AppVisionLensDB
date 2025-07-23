CREATE TABLE [PP].[ALM_MAP_ColumnName] (
    [ColumnMapId]   BIGINT         IDENTITY (1, 1) NOT NULL,
    [ALMColID]      BIGINT         NULL,
    [ProjectColumn] NVARCHAR (200) NOT NULL,
    [ProjectId]     BIGINT         NOT NULL,
    [IsDeleted]     BIT            NOT NULL,
    [CreatedBy]     NVARCHAR (50)  NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    [ModifiedDate]  DATETIME       NULL,
    CONSTRAINT [PK_ALM_MAP_ColumnName_ColumnMapId] PRIMARY KEY CLUSTERED ([ColumnMapId] ASC),
    CONSTRAINT [FK_ALM_MAP_ColumnName_ALMColID] FOREIGN KEY ([ALMColID]) REFERENCES [PP].[ALM_MAS_ColumnName] ([ALMColID]),
    CONSTRAINT [FK_ALM_MAP_ColumnName_ProjectId] FOREIGN KEY ([ProjectId]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

