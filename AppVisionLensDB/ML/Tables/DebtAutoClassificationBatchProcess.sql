CREATE TABLE [ML].[DebtAutoClassificationBatchProcess] (
    [BatchProcessId]              BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectId]                   BIGINT         NOT NULL,
    [SupportTypeId]               TINYINT        NOT NULL,
    [AutoClassificationDetailsId] INT            NOT NULL,
    [ClassificationTypeId]        BIGINT         NOT NULL,
    [ProcessStartDateTime]        DATETIME       NULL,
    [ProcessEndDateTime]          DATETIME       NULL,
    [StatusId]                    BIGINT         NOT NULL,
    [Message]                     NVARCHAR (MAX) NULL,
    [IsDeleted]                   BIT            NOT NULL,
    [CreatedBy]                   NVARCHAR (50)  NOT NULL,
    [CreatedDate]                 DATETIME       NOT NULL,
    [ModifiedBy]                  NVARCHAR (50)  NULL,
    [ModifiedDate]                DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([BatchProcessId] ASC),
    FOREIGN KEY ([AutoClassificationDetailsId]) REFERENCES [AVL].[TK_ProjectForMLClassification] ([AutoClassificationDetailsID]),
    FOREIGN KEY ([ClassificationTypeId]) REFERENCES [MAS].[MachineLearning] ([ID]),
    FOREIGN KEY ([ProjectId]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    FOREIGN KEY ([StatusId]) REFERENCES [MAS].[MachineLearning] ([ID])
);

