CREATE TABLE [MS].[MailLog] (
    [logID]            INT            IDENTITY (1, 1) NOT NULL,
    [ProjectID]        INT            NULL,
    [status]           NVARCHAR (50)  NULL,
    [ErrorDescription] NVARCHAR (MAX) NULL,
    [CreatedDateTime]  DATETIME       NULL,
    [CreatedBY]        NVARCHAR (50)  NULL,
    CONSTRAINT [PK_MainSpringMailLog] PRIMARY KEY CLUSTERED ([logID] ASC) WITH (FILLFACTOR = 70)
);

