CREATE TABLE [AVL].[TK_MAP_SeverityMapping] (
    [SeverityIDMapID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [SeverityID]        BIGINT        NULL,
    [SeverityName]      VARCHAR (500) NULL,
    [ProjectID]         BIGINT        NULL,
    [IsDeleted]         CHAR (1)      NULL,
    [CreatedDateTime]   DATETIME      NULL,
    [CreatedBy]         NVARCHAR (50) NULL,
    [ModifiedDateTime]  DATETIME      NULL,
    [ModifiedBy]        NVARCHAR (50) NULL,
    [IsFixedSource]     CHAR (1)      NULL,
    [IsDefaultSeverity] NVARCHAR (50) NULL,
    [Position]          INT           NULL,
    CONSTRAINT [PK_TK_MAP_SeverityMapping] PRIMARY KEY CLUSTERED ([SeverityIDMapID] ASC),
    CONSTRAINT [FK_TK_MAP_SeverityMapping_MAS_ProjectMaster] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    CONSTRAINT [FK_TK_MAP_SeverityMapping_TK_MAS_Severity] FOREIGN KEY ([SeverityID]) REFERENCES [AVL].[TK_MAS_Severity] ([SeverityID])
);


GO
CREATE NONCLUSTERED INDEX [TK_MAP_SeverityMapping_ProjectID_IsDefaultSeverity]
    ON [AVL].[TK_MAP_SeverityMapping]([ProjectID] ASC, [IsDefaultSeverity] ASC);

