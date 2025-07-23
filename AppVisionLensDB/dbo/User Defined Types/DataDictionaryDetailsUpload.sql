CREATE TYPE [dbo].[DataDictionaryDetailsUpload] AS TABLE (
    [ApplicationName]        NVARCHAR (100) NULL,
    [CauseCode]              NVARCHAR (50)  NULL,
    [ResolutionCode]         NVARCHAR (50)  NULL,
    [DebtCategory]           NVARCHAR (50)  NULL,
    [AvoidableFlag]          NVARCHAR (50)  NULL,
    [ResidualFlag]           NVARCHAR (50)  NULL,
    [ReasonForResidual]      NVARCHAR (50)  NULL,
    [ExpectedCompletionDate] DATETIME       NULL,
    [ProjectID]              BIGINT         NULL,
    [ApplicationID]          BIGINT         NULL);

