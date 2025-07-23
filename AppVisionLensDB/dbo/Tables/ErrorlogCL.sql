CREATE TABLE [dbo].[ErrorlogCL] (
    [ProjectID]    BIGINT         NULL,
    [stepmessage]  NVARCHAR (MAX) NULL,
    [ErrorMessage] NVARCHAR (MAX) NULL,
    [CLErrorId]    BIGINT         IDENTITY (1, 1) NOT NULL,
    [CreateDate]   DATETIME       NULL,
    CONSTRAINT [PK_ErrorlogCL_CLErrorId] PRIMARY KEY CLUSTERED ([CLErrorId] ASC)
);

