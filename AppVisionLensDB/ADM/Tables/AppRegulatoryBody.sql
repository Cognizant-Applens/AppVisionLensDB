CREATE TABLE [ADM].[AppRegulatoryBody] (
    [Id]            BIGINT        IDENTITY (1, 1) NOT NULL,
    [ApplicationId] BIGINT        NULL,
    [RegulatoryId]  BIGINT        NULL,
    [IsDeleted]     BIT           NULL,
    [CreatedBy]     NVARCHAR (50) NULL,
    [CreatedDate]   DATETIME      NULL,
    [ModifiedBy]    NVARCHAR (50) NULL,
    [ModifiedDate]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_RegulatoryId] FOREIGN KEY ([RegulatoryId]) REFERENCES [ADM].[RegulatoryBody] ([ID])
);

