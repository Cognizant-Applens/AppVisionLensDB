CREATE TABLE [AVL].[Debt_TRN_DataDictionaryErrorTemp] (
    [ID]                     BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]              BIGINT         NOT NULL,
    [ApplicationName]        NVARCHAR (MAX) NULL,
    [CauseCode]              NVARCHAR (MAX) NULL,
    [ResolutionCode]         NVARCHAR (MAX) NULL,
    [DebtCategory]           NVARCHAR (MAX) NULL,
    [AvoidableFlag]          NVARCHAR (MAX) NULL,
    [ResidualFlag]           NVARCHAR (MAX) NULL,
    [ReasonForResidual]      NVARCHAR (MAX) NULL,
    [ExpectedCompletionDate] NVARCHAR (MAX) NULL,
    [Remarks]                NVARCHAR (MAX) NULL,
    [IsAllOrSpecific]        NVARCHAR (50)  NULL,
    [IsUpdated]              INT            NULL,
    [IsDeleted]              INT            NULL,
    [CreatedBy]              NVARCHAR (50)  NULL,
    [CreatedOn]              DATETIME       NULL,
    [ModifiedBy]             NVARCHAR (50)  NULL,
    [ModifiedOn]             DATETIME       NULL
);

