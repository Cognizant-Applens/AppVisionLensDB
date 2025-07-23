CREATE TABLE [AVL].[TRN_DebtClassificationModeDetails_Dump] (
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
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

