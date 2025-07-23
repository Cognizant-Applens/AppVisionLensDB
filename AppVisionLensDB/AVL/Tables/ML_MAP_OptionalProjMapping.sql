CREATE TABLE [AVL].[ML_MAP_OptionalProjMapping] (
    [id]              BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectId]       BIGINT         NULL,
    [OptionalFieldID] INT            NULL,
    [IsActive]        BIT            NULL,
    [CreatedBy]       NVARCHAR (500) NULL,
    [CreatedDate]     DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    FOREIGN KEY ([OptionalFieldID]) REFERENCES [AVL].[ML_MAS_OptionalFields] ([ID])
);

