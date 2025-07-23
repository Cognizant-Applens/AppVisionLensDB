CREATE TABLE [BOT].[TargetApplication] (
    [Id]                    BIGINT         IDENTITY (1, 1) NOT NULL,
    [TargetApplicationName] NVARCHAR (100) NULL,
    [IsDeleted]             BIT            NOT NULL,
    [CreatedBy]             NVARCHAR (50)  NOT NULL,
    [CreatedDate]           DATETIME       NOT NULL,
    [ModifiedBy]            NVARCHAR (50)  NULL,
    [ModifiedDate]          DATETIME       NULL,
    CONSTRAINT [PK_TargetApplication] PRIMARY KEY CLUSTERED ([Id] ASC)
);

