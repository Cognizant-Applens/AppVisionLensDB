CREATE TABLE [AVL].[DEBT_MAS_CauseSubCluster] (
    [SubClusterID]   INT           IDENTITY (1, 1) NOT NULL,
    [SubClusterName] VARCHAR (500) NOT NULL,
    [IsDeleted]      BIT           NOT NULL,
    [CreatedBy]      VARCHAR (30)  NOT NULL,
    [CreatedDate]    DATETIME      DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([SubClusterID] ASC)
);

