CREATE TABLE [AVL].[ML_MLBaseDetailsInfra] (
    [Id]                          BIGINT         IDENTITY (1, 1) NOT NULL,
    [InitialLearningID]           BIGINT         NULL,
    [ProjectID]                   BIGINT         NULL,
    [TicketID]                    NVARCHAR (MAX) NULL,
    [TowerName]                   NVARCHAR (MAX) NULL,
    [DebtClassification]          NVARCHAR (MAX) NULL,
    [AvoidableFlag]               NVARCHAR (MAX) NULL,
    [ResidualDebt]                NVARCHAR (MAX) NULL,
    [CauseCode]                   NVARCHAR (MAX) NULL,
    [ResolutionCode]              NVARCHAR (MAX) NULL,
    [TicketDescriptionPattern]    NVARCHAR (MAX) NULL,
    [TicketDescriptionSubPattern] NVARCHAR (MAX) NULL,
    [OptionalFieldpattern]        NVARCHAR (MAX) NULL,
    [OptionalFieldSubPattern]     NVARCHAR (MAX) NULL,
    [Isdeleted]                   BIT            NULL,
    [ContinuousLearningID]        BIGINT         NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

