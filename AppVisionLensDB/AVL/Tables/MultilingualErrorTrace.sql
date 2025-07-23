CREATE TABLE [AVL].[MultilingualErrorTrace] (
    [TimeTickerID]  BIGINT         NULL,
    [TranslateText] NVARCHAR (MAX) NULL,
    [ErrorScope]    NVARCHAR (MAX) NULL,
    [ErrorMessage]  NVARCHAR (MAX) NULL,
    [CreatedBy]     NVARCHAR (50)  NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [SupportType]   INT            NULL
);

