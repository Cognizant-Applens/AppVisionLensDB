CREATE TABLE [BOT].[ErrorLog] (
    [ErrorId]          INT            IDENTITY (1, 1) NOT NULL,
    [CustomerId]       BIGINT         NOT NULL,
    [ErrorSource]      NVARCHAR (MAX) NOT NULL,
    [ErrorDescription] NVARCHAR (MAX) NOT NULL,
    [CreatedBy]        NVARCHAR (50)  NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED ([ErrorId] ASC) WITH (FILLFACTOR = 70)
);

