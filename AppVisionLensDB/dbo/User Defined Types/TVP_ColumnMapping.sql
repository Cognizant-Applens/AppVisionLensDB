CREATE TYPE [dbo].[TVP_ColumnMapping] AS TABLE (
    [UserId]           INT            NULL,
    [ESAProjectID]     BIGINT         NOT NULL,
    [ProjectID]        BIGINT         NOT NULL,
    [ProjectName]      NVARCHAR (MAX) NOT NULL,
    [ApplensColumnID]  INT            NOT NULL,
    [RemedyColumn]     NVARCHAR (MAX) NULL,
    [ServiceNowColumn] NVARCHAR (MAX) NULL,
    [OtherITSMColumn]  NVARCHAR (MAX) NULL);

