CREATE TABLE [MAS].[Cluster] (
    [ClusterID]          BIGINT        IDENTITY (1, 1) NOT NULL,
    [ClusterName]        VARCHAR (500) NOT NULL,
    [CategoryID]         INT           NULL,
    [IsDeleted]          BIT           NULL,
    [CreatedBy]          INT           NULL,
    [CreatedDate]        DATETIME      NULL,
    [ModifiedBy]         INT           NULL,
    [ModifiedDate]       DATETIME      NULL,
    [IsPerformanceIssue] BIT           CONSTRAINT [DF_Cluster_IsPerformanceIssue] DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ClusterID] ASC),
    FOREIGN KEY ([CategoryID]) REFERENCES [MAS].[ClusterCategory] ([CategoryID])
);


GO
CREATE NONCLUSTERED INDEX [Index_Cluster]
    ON [MAS].[Cluster]([ClusterID] ASC, [IsDeleted] ASC);

