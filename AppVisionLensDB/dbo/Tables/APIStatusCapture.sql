CREATE TABLE [dbo].[APIStatusCapture] (
    [ID]          INT           IDENTITY (1, 1) NOT NULL,
    [ProjectID]   BIGINT        NULL,
    [UserID]      NVARCHAR (50) NULL,
    [Request]     VARCHAR (200) NULL,
    [Responce]    VARCHAR (200) NULL,
    [Mode]        VARCHAR (50)  NULL,
    [CreatedDate] DATETIME      NULL
);

