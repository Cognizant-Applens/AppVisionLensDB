CREATE TABLE [RLE].[GroupsMapping] (
    [GroupMappingId]  INT          IDENTITY (1, 1) NOT NULL,
    [GroupID]         INT          NULL,
    [Isdeleted]       BIT          DEFAULT ((0)) NULL,
    [CreatedBy]       VARCHAR (50) NULL,
    [CreatedDate]     DATETIME     NULL,
    [ModifiedBy]      VARCHAR (50) NULL,
    [ModifiedDate]    DATETIME     NULL,
    [AssociateTypeId] INT          NULL,
    PRIMARY KEY CLUSTERED ([GroupMappingId] ASC),
    FOREIGN KEY ([GroupID]) REFERENCES [MAS].[RLE_Groups] ([GroupID]),
    CONSTRAINT [FK_Associate_Type_Id] FOREIGN KEY ([AssociateTypeId]) REFERENCES [MAS].[AssociateType] ([Id])
);

