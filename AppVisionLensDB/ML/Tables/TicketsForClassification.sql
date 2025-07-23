CREATE TABLE [ML].[TicketsForClassification] (
    [ID]                       BIGINT         IDENTITY (1, 1) NOT NULL,
    [BatchProcessId]           BIGINT         NOT NULL,
    [ApplicationId]            BIGINT         NOT NULL,
    [TicketId]                 NVARCHAR (50)  NOT NULL,
    [TicketDescription]        NVARCHAR (MAX) NULL,
    [AdditionalText]           NVARCHAR (MAX) NULL,
    [CauseCodeId]              BIGINT         NULL,
    [ResolutionCodeId]         BIGINT         NULL,
    [DescWorkPattern]          NVARCHAR (500) NULL,
    [DescSubWorkPattern]       NVARCHAR (500) NULL,
    [ResolutionWorkPattern]    NVARCHAR (500) NULL,
    [ResolutionSubWorkPattern] NVARCHAR (500) NULL,
    [DebtClassificationId]     INT            NULL,
    [AvoidableFlagId]          INT            NULL,
    [ResidualFlagId]           INT            NULL,
    [RuleId]                   INT            NULL,
    [LWRuleId]                 INT            NULL,
    [LWRuleLevel]              VARCHAR (10)   NULL,
    [StatusId]                 BIGINT         NOT NULL,
    [IsDeleted]                BIT            NOT NULL,
    [CreatedBy]                NVARCHAR (50)  NOT NULL,
    [CreatedDate]              DATETIME       NOT NULL,
    [ModifiedBy]               NVARCHAR (50)  NULL,
    [ModifiedDate]             DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    FOREIGN KEY ([BatchProcessId]) REFERENCES [ML].[DebtAutoClassificationBatchProcess] ([BatchProcessId]),
    FOREIGN KEY ([BatchProcessId]) REFERENCES [ML].[DebtAutoClassificationBatchProcess] ([BatchProcessId]),
    FOREIGN KEY ([StatusId]) REFERENCES [MAS].[MachineLearning] ([ID]),
    FOREIGN KEY ([StatusId]) REFERENCES [MAS].[MachineLearning] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [NON_IX_TicketsForClassification_BatchProcessId_IsDeleted]
    ON [ML].[TicketsForClassification]([BatchProcessId] ASC, [IsDeleted] ASC)
    INCLUDE([ApplicationId]);


GO
CREATE NONCLUSTERED INDEX [NON_IX_TicketsForClassification_DebtClassification]
    ON [ML].[TicketsForClassification]([StatusId] ASC, [IsDeleted] ASC, [ApplicationId] ASC, [BatchProcessId] ASC)
    INCLUDE([TicketId], [CauseCodeId], [ResolutionCodeId], [TicketDescription], [AdditionalText]);


GO
CREATE NONCLUSTERED INDEX [NON_IX_TicketsForClassification_DebtClassificationCCRR]
    ON [ML].[TicketsForClassification]([StatusId] ASC, [IsDeleted] ASC, [ApplicationId] ASC, [BatchProcessId] ASC)
    INCLUDE([TicketId], [TicketDescription], [AdditionalText]);


GO
CREATE NONCLUSTERED INDEX [NON_IX_TicketsForClassification_DebtClassificationWorkPattern]
    ON [ML].[TicketsForClassification]([StatusId] ASC, [IsDeleted] ASC, [ApplicationId] ASC, [BatchProcessId] ASC)
    INCLUDE([TicketId], [CauseCodeId], [ResolutionCodeId], [DescWorkPattern], [DescSubWorkPattern], [ResolutionWorkPattern], [ResolutionSubWorkPattern]);

