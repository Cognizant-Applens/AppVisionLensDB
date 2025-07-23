CREATE TABLE [ML].[ConfigurationProgress] (
    [ID]                               BIGINT         IDENTITY (1000, 1) NOT NULL,
    [ProjectID]                        BIGINT         NOT NULL,
    [FromDate]                         DATETIME       NOT NULL,
    [ToDate]                           DATETIME       NOT NULL,
    [IsOptionalField]                  BIT            NOT NULL,
    [DebtAttributeId]                  BIGINT         NOT NULL,
    [IsNoiseEliminationSentorReceived] NVARCHAR (100) NULL,
    [IsNoiseSkipped]                   BIT            NULL,
    [IsSamplingSentOrReceived]         NVARCHAR (100) NULL,
    [IsSamplingInProgress]             NVARCHAR (100) NULL,
    [IsMLSentOrReceived]               NVARCHAR (100) NULL,
    [IsDeleted]                        BIT            NOT NULL,
    [CreatedBy]                        NVARCHAR (50)  NULL,
    [CreatedDate]                      DATETIME       NULL,
    [ModifiedBy]                       NVARCHAR (50)  NULL,
    [ModifiedDate]                     DATETIME       NULL,
    [IsTicketDescriptionOpted]         BIT            NULL,
    [IsWorkPatternUploadCompleted]     BIT            NULL,
    [IsWorkPatternPrereqCompleted]     BIT            NULL,
    [IsSamplingSkipped]                BIT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    FOREIGN KEY ([DebtAttributeId]) REFERENCES [MAS].[MachineLearning] ([ID])
);


GO
CREATE NONCLUSTERED INDEX [Idx_ProjectID_IsDeleted]
    ON [ML].[ConfigurationProgress]([ProjectID] ASC, [IsDeleted] ASC);

