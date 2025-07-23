CREATE TABLE [AVL].[PRJ_MultilingualColumnMapping] (
    [ProjectColumnMapID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]          BIGINT        NOT NULL,
    [ColumnID]           INT           NOT NULL,
    [IsActive]           BIT           NULL,
    [CreatedBy]          NVARCHAR (10) NOT NULL,
    [CreatedDate]        DATETIME      NOT NULL,
    [ModifiedBy]         NVARCHAR (10) NULL,
    [ModifiedDate]       DATETIME      NULL,
    FOREIGN KEY ([ColumnID]) REFERENCES [AVL].[MAS_MultilingualColumnMaster] ([ColumnID]),
    FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);


GO
CREATE NONCLUSTERED INDEX [INX_PRJ_MultilingualColumnMapping_ProjId_ColID_IsActive]
    ON [AVL].[PRJ_MultilingualColumnMapping]([ProjectID] ASC, [ColumnID] ASC, [IsActive] ASC);

