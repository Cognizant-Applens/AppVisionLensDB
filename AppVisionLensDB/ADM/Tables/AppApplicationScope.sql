CREATE TABLE [ADM].[AppApplicationScope] (
    [Id]                 BIGINT        IDENTITY (1, 1) NOT NULL,
    [ApplicationId]      BIGINT        NULL,
    [ApplicationScopeId] BIGINT        NULL,
    [IsDeleted]          BIT           NULL,
    [CreatedBy]          NVARCHAR (50) NULL,
    [CreatedDate]        DATETIME      NULL,
    [ModifiedBy]         NVARCHAR (50) NULL,
    [ModifiedDate]       DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ApplicationScopeId] FOREIGN KEY ([ApplicationScopeId]) REFERENCES [ADM].[ApplicationScope] ([ID])
);

