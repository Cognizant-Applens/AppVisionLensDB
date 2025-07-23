CREATE TABLE [BOT].[Intermediate_QB] (
    [TimeTickerID]  BIGINT         NOT NULL,
    [DescDecrypted] NVARCHAR (MAX) NULL,
    [SummDecrypted] NVARCHAR (MAX) NULL,
    [IsDeleted]     BIT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [CreatedBy]     NVARCHAR (50)  NOT NULL,
    [ModifiedDate]  DATETIME       NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    CONSTRAINT [PK_Intermediate_QB] PRIMARY KEY CLUSTERED ([TimeTickerID] ASC)
);

