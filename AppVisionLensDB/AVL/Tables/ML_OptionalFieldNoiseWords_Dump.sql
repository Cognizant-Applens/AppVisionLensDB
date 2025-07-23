CREATE TABLE [AVL].[ML_OptionalFieldNoiseWords_Dump] (
    [ID]                     BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]              BIGINT         NULL,
    [OptionalFieldNoiseWord] NVARCHAR (500) NULL,
    [Frequency]              BIGINT         NULL,
    [IsActive]               BIT            NULL,
    [CreatedDate]            DATETIME       NULL,
    [CreatedBy]              NVARCHAR (500) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

