CREATE TABLE [AVL].[ML_MAP_OptionalProjMappingInfra] (
    [Id]              BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectId]       BIGINT        NOT NULL,
    [OptionalFieldID] INT           NULL,
    [IsDeleted]       BIT           NULL,
    [CreatedBy]       NVARCHAR (50) NULL,
    [CreatedDate]     DATETIME      NULL,
    [ModifiedBy]      NVARCHAR (50) NULL,
    [ModifiedDate]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

