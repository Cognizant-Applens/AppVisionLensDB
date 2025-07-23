CREATE TYPE [AVL].[TVP_DataDictionaryDetailsUpload] AS TABLE (
    [ApplicationName]        NVARCHAR (MAX) NULL,
    [CauseCode]              NVARCHAR (MAX) NULL,
    [ResolutionCode]         NVARCHAR (MAX) NULL,
    [DebtCategory]           NVARCHAR (MAX) NULL,
    [AvoidableFlag]          NVARCHAR (MAX) NULL,
    [ResidualFlag]           NVARCHAR (MAX) NULL,
    [ReasonForResidual]      NVARCHAR (MAX) NULL,
    [ExpectedCompletionDate] NVARCHAR (MAX) NULL);

