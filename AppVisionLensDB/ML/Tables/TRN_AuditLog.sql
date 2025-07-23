CREATE TABLE [ML].[TRN_AuditLog] (
    [AuditLogId]      BIGINT         IDENTITY (1, 1) NOT NULL,
    [MLTransactionId] BIGINT         NOT NULL,
    [LearningTypeKey] NVARCHAR (6)   NOT NULL,
    [SignOffDate]     DATETIME       NULL,
    [Total]           INT            NULL,
    [ModelVersion]    INT            NOT NULL,
    [Comments]        NVARCHAR (250) NULL,
    [PRFromDate]      DATETIME       NULL,
    [PRToDate]        DATETIME       NULL,
    [IsDeleted]       BIT            NOT NULL,
    [CreatedBy]       NVARCHAR (50)  NOT NULL,
    [CreatedDate]     DATETIME       NOT NULL,
    [ModifiedBy]      NVARCHAR (50)  NULL,
    [ModifiedDate]    DATETIME       NULL,
    [SignOffBy]       NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([AuditLogId] ASC),
    FOREIGN KEY ([MLTransactionId]) REFERENCES [ML].[TRN_MLTransaction] ([TransactionId]),
    FOREIGN KEY ([MLTransactionId]) REFERENCES [ML].[TRN_MLTransaction] ([TransactionId])
);

