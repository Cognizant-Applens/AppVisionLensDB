CREATE TABLE [ADM].[AppGeographies] (
    [Id]            BIGINT        IDENTITY (1, 1) NOT NULL,
    [ApplicationId] BIGINT        NULL,
    [GeographyId]   BIGINT        NULL,
    [IsDeleted]     BIT           NULL,
    [CreatedBy]     NVARCHAR (50) NULL,
    [CreatedDate]   DATETIME      NULL,
    [ModifiedBy]    NVARCHAR (50) NULL,
    [ModifiedDate]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_GeographyId] FOREIGN KEY ([GeographyId]) REFERENCES [ADM].[GeographiesSupported] ([ID])
);

