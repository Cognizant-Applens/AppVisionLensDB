CREATE TABLE [AVL].[BusinessCluster] (
    [BusinessClusterID]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [BusinessClusterName]     NVARCHAR (50) NOT NULL,
    [ParentBusinessClusterID] BIGINT        NULL,
    [IsHavingSubBusinesss]    BIT           NOT NULL,
    [IsDeleted]               BIT           NOT NULL,
    [CustomerID]              BIGINT        NOT NULL,
    [CreatedBy]               NVARCHAR (50) NOT NULL,
    [CreatedDate]             DATETIME      CONSTRAINT [DF_buisness_cluster_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]              NVARCHAR (50) NULL,
    [ModifiedDate]            DATETIME      NULL,
    CONSTRAINT [PK_buisness_cluster] PRIMARY KEY CLUSTERED ([BusinessClusterID] ASC),
    CONSTRAINT [FK_BusinessCluster_Customer] FOREIGN KEY ([CustomerID]) REFERENCES [AVL].[Customer] ([CustomerID])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_BusinessCluster_IsHavingSubBusinesss_CustomerID]
    ON [AVL].[BusinessCluster]([IsHavingSubBusinesss] ASC, [CustomerID] ASC);


GO
CREATE NONCLUSTERED INDEX [BusinessCluster_CustomerID_IsDeleted]
    ON [AVL].[BusinessCluster]([IsDeleted] ASC, [CustomerID] ASC);

