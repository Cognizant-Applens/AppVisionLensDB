CREATE TABLE [AVL].[EmailCollection] (
    [Id]        INT            IDENTITY (1, 1) NOT NULL,
    [ToAddress] NVARCHAR (MAX) NULL,
    [CC]        NVARCHAR (MAX) NULL,
    [Bcc]       NVARCHAR (MAX) NULL,
    [Subject]   NVARCHAR (MAX) NULL,
    [Body]      NVARCHAR (MAX) NULL,
    [Status]    INT            NULL,
    [Scenario]  INT            NULL,
    [Date]      DATETIME       NULL,
    [FilePath]  NVARCHAR (MAX) NULL
);

