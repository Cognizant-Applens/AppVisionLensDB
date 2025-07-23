CREATE TABLE [ML].[BaseDetails] (
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
    [ContinuousLearningID]        BIGINT         CONSTRAINT [DF_ML_BaseDetails_ContinuousLearningID] DEFAULT (NULL) NULL,
    [CreatedBy]                   NVARCHAR (50)  NULL,
    [CreatedDate]                 DATETIME       NULL,
    [ModifiedBy]                  NVARCHAR (50)  NULL,
    [ModifiedDate]                DATETIME       NULL
);


GO
CREATE NONCLUSTERED INDEX [Idx_ProjectID_IsDeleted]
    ON [ML].[BaseDetails]([ProjectID] ASC, [Isdeleted] ASC)
    INCLUDE([TicketID]);

