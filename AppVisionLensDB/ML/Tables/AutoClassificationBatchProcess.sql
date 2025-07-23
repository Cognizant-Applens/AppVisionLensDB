CREATE TABLE [ML].[AutoClassificationBatchProcess] (
    [BatchProcessId]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectId]            BIGINT        NOT NULL,
    [EmployeeID]           NVARCHAR (50) NOT NULL,
    [IsAutoClassified]     CHAR (1)      NULL,
    [IsDDAutoClassified]   CHAR (1)      NULL,
    [AlgorithmKey]         NVARCHAR (6)  NULL,
    [StatusId]             BIGINT        NOT NULL,
    [ProcessStartDateTime] DATETIME      NULL,
    [ProcessEndDateTime]   DATETIME      NULL,
    [IsDeleted]            BIT           NULL,
    [CreatedBy]            NVARCHAR (50) NULL,
    [CreatedDate]          DATETIME      NULL,
    [ModifiedBy]           NVARCHAR (50) NULL,
    [ModifiedDate]         DATETIME      NULL,
    [TransactionIdApp]     BIGINT        NULL,
    [TransactionIdInfra]   BIGINT        NULL,
    PRIMARY KEY CLUSTERED ([BatchProcessId] ASC),
    FOREIGN KEY ([ProjectId]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    FOREIGN KEY ([StatusId]) REFERENCES [MAS].[MachineLearning] ([ID])
);

