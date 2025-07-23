CREATE TYPE [dbo].[TVP_ITSMCauseCodeList] AS TABLE (
    [CauseId]       BIGINT         NULL,
    [CauseStatusId] BIGINT         NULL,
    [CauseCodeName] NVARCHAR (200) NULL,
    [MCauseCode]    NVARCHAR (200) NULL);

