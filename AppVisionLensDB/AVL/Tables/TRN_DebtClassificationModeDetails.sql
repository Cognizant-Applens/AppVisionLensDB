CREATE TABLE [AVL].[TRN_DebtClassificationModeDetails] (
    [ID]                         BIGINT         IDENTITY (1, 1) NOT NULL,
    [TimeTickerID]               BIGINT         NULL,
    [SystemDebtclassification]   BIGINT         NULL,
    [SystemAvoidableFlag]        BIGINT         NULL,
    [SystemResidualDebtFlag]     BIGINT         NULL,
    [UserDebtClassificationFlag] BIGINT         NULL,
    [UserAvoidableFlag]          BIGINT         NULL,
    [UserResidualDebtFlag]       BIGINT         NULL,
    [DebtClassficationMode]      BIGINT         NULL,
    [SourceForPattern]           BIGINT         NULL,
    [Isdeleted]                  BIT            NULL,
    [CreatedBy]                  NVARCHAR (MAX) NULL,
    [CreatedDate]                DATETIME       NULL,
    [ModifiedDate]               DATETIME       NULL,
    [ModifiedBy]                 NVARCHAR (MAX) NULL,
    [CauseCodeID]                BIGINT         NULL,
    [ResolutionCodeID]           BIGINT         NULL,
    [SystemCauseCodeID]          BIGINT         NULL,
    [SystemResolutionCodeID]     BIGINT         NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TRN_DebtClassificationModeDetails_TimeTickerID]
    ON [AVL].[TRN_DebtClassificationModeDetails]([TimeTickerID] ASC);

