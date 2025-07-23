CREATE TABLE [MAS].[AssociateType] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [Type]         VARCHAR (100) NULL,
    [Isdeleted]    BIT           DEFAULT ((0)) NULL,
    [CreatedBy]    VARCHAR (50)  NULL,
    [CreatedDate]  DATETIME      NULL,
    [ModifiedBy]   VARCHAR (50)  NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

