CREATE TABLE [ML].[InfraConfigurationProgress] (
    [ID]                               BIGINT        IDENTITY (1000, 1) NOT NULL,
    [ProjectID]                        BIGINT        NOT NULL,
    [FromDate]                         DATETIME      NOT NULL,
    [ToDate]                           DATETIME      NOT NULL,
    [IsOptionalField]                  BIT           NOT NULL,
    [DebtAttributeId]                  BIGINT        NOT NULL,
    [IsNoiseEliminationSentorReceived] NVARCHAR (50) NULL,
    [IsNoiseSkipped]                   BIT           NULL,
    [IsSamplingSentOrReceived]         NVARCHAR (50) NULL,
    [IsSamplingInProgress]             NVARCHAR (50) NULL,
    [IsMLSentOrReceived]               NVARCHAR (50) NULL,
    [IsDeleted]                        BIT           NOT NULL,
    [CreatedBy]                        NVARCHAR (50) NULL,
    [CreatedDate]                      DATETIME      NULL,
    [ModifiedBy]                       NVARCHAR (50) NULL,
    [ModifiedDate]                     DATETIME      NULL,
    [IsTicketDescriptionOpted]         BIT           NULL,
    [IsSamplingSkipped]                BIT           NULL,
    [IsRegenerate]                     BIT           CONSTRAINT [D_InfraConfigurationProgress_IsRegenerate] DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    FOREIGN KEY ([DebtAttributeId]) REFERENCES [MAS].[MachineLearning] ([ID])
);

