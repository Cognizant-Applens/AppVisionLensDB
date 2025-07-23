CREATE TABLE [ML].[InfraBaseDetails] (
    [InitialLearningID]           BIGINT         NULL,
    [ProjectID]                   BIGINT         NULL,
    [TicketID]                    NVARCHAR (50)  NULL,
    [TowerName]                   NVARCHAR (200) NULL,
    [DebtClassification]          NVARCHAR (50)  NULL,
    [AvoidableFlag]               NVARCHAR (10)  NULL,
    [ResidualDebt]                NVARCHAR (10)  NULL,
    [CauseCode]                   NVARCHAR (200) NULL,
    [ResolutionCode]              NVARCHAR (200) NULL,
    [TicketDescriptionPattern]    NVARCHAR (200) NULL,
    [TicketDescriptionSubPattern] NVARCHAR (200) NULL,
    [OptionalFieldpattern]        NVARCHAR (200) NULL,
    [OptionalFieldSubPattern]     NVARCHAR (200) NULL,
    [Isdeleted]                   BIT            NULL,
    [ContinuousLearningID]        BIGINT         CONSTRAINT [DF_ML_InfraBaseDetails_ContinuousLearningID] DEFAULT (NULL) NULL,
    [CreatedBy]                   NVARCHAR (50)  NULL,
    [CreatedDate]                 DATETIME       NULL,
    [ModifiedBy]                  NVARCHAR (50)  NULL,
    [ModifiedDate]                DATETIME       NULL
);

