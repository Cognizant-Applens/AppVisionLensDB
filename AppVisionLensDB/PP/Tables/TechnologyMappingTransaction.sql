CREATE TABLE [PP].[TechnologyMappingTransaction] (
    [Id]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [AccountId]      BIGINT        NOT NULL,
    [ApplicationId]  INT           NOT NULL,
    [AppicationName] VARCHAR (200) NOT NULL,
    [EolId]          INT           NULL,
    [Remarks]        VARCHAR (MAX) NULL,
    [ExpiryFlag]     CHAR (2)      NULL,
    [IsUserCreated]  BIT           NULL,
    [IsDeleted]      BIT           NULL,
    [CreatedBy]      NVARCHAR (50) NULL,
    [CreatedDate]    DATETIME      NULL,
    [ModifiedBy]     NVARCHAR (50) NULL,
    [ModifiedDate]   DATETIME      NULL,
    [ProductType]    VARCHAR (100) NULL,
    [Product]        VARCHAR (100) NULL,
    [Version]        VARCHAR (50)  NULL,
    [Update]         VARCHAR (100) NULL,
    [Edition]        VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

