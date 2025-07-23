CREATE TABLE [dbo].[TimesheetUnfreezeDetails_L2Team] (
    [ID]           BIGINT          IDENTITY (1, 1) NOT NULL,
    [EsaProjectID] NVARCHAR (100)  NOT NULL,
    [ProjectID]    BIGINT          NOT NULL,
    [ProjectName]  NVARCHAR (100)  NULL,
    [RequestedBy]  NVARCHAR (100)  NULL,
    [UnfreezeFrom] DATE            NOT NULL,
    [UnfreezeTo]   DATE            NOT NULL,
    [CreatedDate]  DATETIME        NULL,
    [Comments]     NVARCHAR (1000) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

