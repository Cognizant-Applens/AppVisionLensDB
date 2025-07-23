CREATE TABLE [BOT].[BOTAutomationTechnology] (
    [Id]                   INT            NOT NULL,
    [AutomationTechnology] NVARCHAR (200) NULL,
    [IsDeleted]            BIT            NOT NULL,
    [CreatedBy]            NVARCHAR (50)  NOT NULL,
    [CreatedDate]          DATETIME       NOT NULL,
    [ModifiedBy]           NVARCHAR (50)  NULL,
    [ModifiedDate]         DATETIME       NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

