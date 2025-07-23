CREATE TABLE [AVL].[DEBT_MAP_CauseCode] (
    [CauseID]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [CauseCode]        NVARCHAR (500) NULL,
    [CauseStatusID]    BIGINT         NULL,
    [ProjectID]        BIGINT         NOT NULL,
    [IsHealConsidered] CHAR (1)       CONSTRAINT [DF_DEBT_MAP_CauseCode_IsHealConsidered] DEFAULT ('Y') NULL,
    [IsDeleted]        BIT            NOT NULL,
    [CreatedBy]        NVARCHAR (50)  NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [ModifiedBy]       NVARCHAR (50)  NULL,
    [ModifiedDate]     DATETIME       NULL,
    [MCauseCode]       NVARCHAR (500) NULL,
    CONSTRAINT [PK__DEBT_MAP__BC664993876E5707] PRIMARY KEY CLUSTERED ([CauseID] ASC),
    CONSTRAINT [FK_DEBT_MAP_CauseCode_MAS_Cluster] FOREIGN KEY ([CauseStatusID]) REFERENCES [MAS].[Cluster] ([ClusterID]),
    CONSTRAINT [FK_DEBT_MAP_CauseCode_MAS_ProjectMaster] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);


GO
CREATE NONCLUSTERED INDEX [IX_DEBT_MAP_CauseCode_ProjectID]
    ON [AVL].[DEBT_MAP_CauseCode]([ProjectID] ASC, [IsDeleted] ASC);

