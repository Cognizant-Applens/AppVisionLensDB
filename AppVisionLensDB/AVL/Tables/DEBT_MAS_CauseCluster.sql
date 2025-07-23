CREATE TABLE [AVL].[DEBT_MAS_CauseCluster] (
    [ClusterID]   INT           IDENTITY (1, 1) NOT NULL,
    [ClusterName] VARCHAR (500) NOT NULL,
    [IsDeleted]   BIT           NOT NULL,
    [CreatedBy]   VARCHAR (30)  NOT NULL,
    [CreatedDate] DATETIME      DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([ClusterID] ASC)
);

