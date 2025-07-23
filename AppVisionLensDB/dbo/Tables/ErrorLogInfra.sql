CREATE TABLE [dbo].[ErrorLogInfra] (
    [ID]          INT           IDENTITY (1, 1) NOT NULL,
    [Step]        VARCHAR (MAX) NULL,
    [Content]     VARCHAR (MAX) NULL,
    [CreatedDate] DATETIME      NULL
);

