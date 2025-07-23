CREATE TABLE [AVL].[BusinessClusterMapping] (
    [BusinessClusterMapID]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [BusinessClusterBaseName]    NVARCHAR (50) NOT NULL,
    [BusinessClusterID]          BIGINT        NULL,
    [ParentBusinessClusterMapID] BIGINT        NULL,
    [IsHavingSubBusinesss]       BIT           NOT NULL,
    [IsDeleted]                  BIT           NOT NULL,
    [CustomerID]                 BIGINT        NOT NULL,
    [CreatedBy]                  NVARCHAR (50) NOT NULL,
    [CreatedDate]                DATETIME      CONSTRAINT [DF_BusinessClusterMapping_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]                 NVARCHAR (50) NULL,
    [ModifiedDate]               DATETIME      NULL,
    CONSTRAINT [PK_BusinessClusterMapID] PRIMARY KEY CLUSTERED ([BusinessClusterMapID] ASC),
    CONSTRAINT [FK_BusinessClusterMapping_BusinessCluster] FOREIGN KEY ([BusinessClusterID]) REFERENCES [AVL].[BusinessCluster] ([BusinessClusterID])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_BusinessClusterMapping_IsDeleted_CustomerID]
    ON [AVL].[BusinessClusterMapping]([IsDeleted] ASC, [CustomerID] ASC)
    INCLUDE([BusinessClusterMapID], [BusinessClusterBaseName], [ParentBusinessClusterMapID], [IsHavingSubBusinesss]);


GO
CREATE NONCLUSTERED INDEX [IDX_BCBaseName_ISHavingSubBusinesss]
    ON [AVL].[BusinessClusterMapping]([ParentBusinessClusterMapID] ASC)
    INCLUDE([BusinessClusterBaseName], [IsHavingSubBusinesss]);


GO
CREATE NONCLUSTERED INDEX [NC_BusinessClusterMapping_CustomerID]
    ON [AVL].[BusinessClusterMapping]([CustomerID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_BusinessClusterMapping_BusinessClusterMapID_IsDeleted]
    ON [AVL].[BusinessClusterMapping]([BusinessClusterMapID] ASC, [IsDeleted] ASC)
    INCLUDE([BusinessClusterBaseName], [BusinessClusterID], [ParentBusinessClusterMapID]);

