CREATE TABLE [ML].[TRN_Clustering_OutCome_App] (
    [ClusteringId]          INT           IDENTITY (1, 1) NOT NULL,
    [MLTransactionId]       BIGINT        NOT NULL,
    [ApplicationId]         BIGINT        NOT NULL,
    [ITSMTicketCount]       INT           NOT NULL,
    [ClusteringTicketCount] INT           NOT NULL,
    [CCForID]               INT           NOT NULL,
    [CCForRR]               INT           NOT NULL,
    [RatingKey]             NVARCHAR (6)  NULL,
    [IsDeleted]             BIT           NOT NULL,
    [CreatedBy]             NVARCHAR (50) NOT NULL,
    [CreatedDate]           DATETIME      NOT NULL,
    [ModifiedBy]            NVARCHAR (50) NULL,
    [ModifiedDate]          DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ClusteringId] ASC),
    FOREIGN KEY ([ApplicationId]) REFERENCES [AVL].[APP_MAS_ApplicationDetails] ([ApplicationID]),
    FOREIGN KEY ([ApplicationId]) REFERENCES [AVL].[APP_MAS_ApplicationDetails] ([ApplicationID]),
    FOREIGN KEY ([MLTransactionId]) REFERENCES [ML].[TRN_MLTransaction] ([TransactionId]),
    FOREIGN KEY ([MLTransactionId]) REFERENCES [ML].[TRN_MLTransaction] ([TransactionId])
);

