CREATE TABLE [RLE].[ExternalUserDetails] (
    [Id]                  INT           IDENTITY (1, 1) NOT NULL,
    [UserId]              VARCHAR (100) NULL,
    [Status]              VARCHAR (50)  NULL,
    [Email]               VARCHAR (100) NULL,
    [FirstName]           VARCHAR (100) NULL,
    [LastName]            VARCHAR (100) NULL,
    [FullName]            VARCHAR (100) NULL,
    [Country]             VARCHAR (50)  NULL,
    [City]                VARCHAR (50)  NULL,
    [UserType]            VARCHAR (50)  NULL,
    [ProjectId]           VARCHAR (50)  NULL,
    [RequestorId]         VARCHAR (50)  NULL,
    [Description]         VARCHAR (500) NULL,
    [AccountExpiryDate]   VARCHAR (50)  NULL,
    [AccountCreationDate] VARCHAR (50)  NULL,
    [Isdeleted]           BIT           NULL,
    [CreatedBy]           VARCHAR (50)  NULL,
    [CreatedDate]         DATETIME      NULL,
    [ModifiedBy]          VARCHAR (50)  NULL,
    [ModifiedDate]        DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

