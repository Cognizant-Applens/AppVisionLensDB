CREATE TABLE [ML].[MLBaseDetails] (
    [InitialLearningID]           BIGINT         NULL,
    [ProjectID]                   BIGINT         NULL,
    [TicketID]                    NVARCHAR (MAX) NULL,
    [ApplicationName]             NVARCHAR (MAX) NULL,
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
    [ContinuousLearningID]        BIGINT         CONSTRAINT [DF_MLBaseDetails_ContinuousLearningID] DEFAULT (NULL) NULL,
    [CreatedBy]                   NVARCHAR (50)  NULL,
    [CreatedDate]                 DATETIME       NULL,
    [ModifiedBy]                  NVARCHAR (50)  NULL,
    [ModifiedDate]                DATETIME       NULL
);

