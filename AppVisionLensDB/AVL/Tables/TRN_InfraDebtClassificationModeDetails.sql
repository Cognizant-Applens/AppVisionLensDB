CREATE TABLE [AVL].[TRN_InfraDebtClassificationModeDetails] (
    [ID]                         BIGINT          IDENTITY (1, 1) NOT NULL,
    [TimeTickerID]               BIGINT          NULL,
    [SystemDebtclassification]   INT             NULL,
    [SystemAvoidableFlag]        INT             NULL,
    [SystemResidualDebtFlag]     INT             NULL,
    [UserDebtClassificationFlag] INT             NULL,
    [UserAvoidableFlag]          INT             NULL,
    [UserResidualDebtFlag]       INT             NULL,
    [DebtClassficationMode]      INT             NULL,
    [SourceForPattern]           INT             NULL,
    [Isdeleted]                  BIT             NULL,
    [CreatedBy]                  NVARCHAR (4000) NULL,
    [CreatedDate]                DATETIME        NULL,
    [ModifiedDate]               DATETIME        NULL,
    [ModifiedBy]                 NVARCHAR (4000) NULL,
    [CauseCodeID]                BIGINT          NULL,
    [ResolutionCodeID]           BIGINT          NULL,
    [SystemCauseCodeID]          BIGINT          NULL,
    [SystemResolutionCodeID]     BIGINT          NULL
);

