CREATE TYPE [dbo].[TVP_DataMapping] AS TABLE (
    [UserId]          INT            NULL,
    [ESAProjectID]    BIGINT         NOT NULL,
    [ProjectID]       BIGINT         NOT NULL,
    [ProjectName]     NVARCHAR (MAX) NOT NULL,
    [ApplensColumnID] INT            NOT NULL,
    [ApplensDataID]   INT            NOT NULL,
    [RemedyData]      NVARCHAR (MAX) NULL,
    [ServiceData]     NVARCHAR (MAX) NULL,
    [OtherData]       NVARCHAR (MAX) NULL);

