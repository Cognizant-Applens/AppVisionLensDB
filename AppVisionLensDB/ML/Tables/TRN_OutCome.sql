CREATE TABLE [ML].[TRN_OutCome] (
    [OutComeId]       INT           IDENTITY (1, 1) NOT NULL,
    [MLTransactionId] BIGINT        NOT NULL,
    [MinimumPoint]    INT           NULL,
    [Threshold]       INT           NULL,
    [ThresholdRange]  INT           NULL,
    [Level2Id]        SMALLINT      NULL,
    [IsDeleted]       BIT           NOT NULL,
    [CreatedBy]       NVARCHAR (50) NOT NULL,
    [CreatedDate]     DATETIME      NOT NULL,
    [ModifiedBy]      NVARCHAR (50) NULL,
    [ModifiedDate]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([OutComeId] ASC),
    FOREIGN KEY ([MLTransactionId]) REFERENCES [ML].[TRN_MLTransaction] ([TransactionId]),
    FOREIGN KEY ([MLTransactionId]) REFERENCES [ML].[TRN_MLTransaction] ([TransactionId])
);

