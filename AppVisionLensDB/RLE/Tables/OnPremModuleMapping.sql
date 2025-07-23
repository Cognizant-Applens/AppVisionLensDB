CREATE TABLE [RLE].[OnPremModuleMapping] (
    [Id]            INT          IDENTITY (1, 1) NOT NULL,
    [RoleMappingID] BIGINT       NULL,
    [Isdeleted]     BIT          DEFAULT ((0)) NULL,
    [CreatedBy]     VARCHAR (50) NULL,
    [CreatedDate]   DATETIME     NULL,
    [ModifiedBy]    VARCHAR (50) NULL,
    [ModifiedDate]  DATETIME     NULL,
    [ModuleId]      INT          NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_OnPremModuleMapping_ModuleId] FOREIGN KEY ([ModuleId]) REFERENCES [MAS].[Modules] ([ModuleId])
);

