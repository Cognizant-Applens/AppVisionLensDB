CREATE TABLE [AVL].[NoiseWords] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [NoiseWord]  VARCHAR (100) NULL,
    [IsDeleted]  BIT           NULL,
    [CreatedBy]  NVARCHAR (50) NULL,
    [CreatedOn]  DATETIME      NULL,
    [ModifiedBy] NVARCHAR (50) NULL,
    [ModifiedOn] DATETIME      NULL,
    CONSTRAINT [PK_NoiseWords] PRIMARY KEY CLUSTERED ([Id] ASC)
);

