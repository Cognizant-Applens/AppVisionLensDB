CREATE TABLE [AVL].[ML_OptionalFieldNoiseWordsInfra] (
    [Id]                     BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]              BIGINT         NOT NULL,
    [OptionalFieldNoiseWord] NVARCHAR (500) NULL,
    [Frequency]              INT            NULL,
    [IsDeleted]              BIT            NULL,
    [CreatedBy]              NVARCHAR (50)  NULL,
    [CreatedDate]            DATETIME       NULL,
    [ModifiedBy]             NVARCHAR (50)  NULL,
    [ModifiedDate]           DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

