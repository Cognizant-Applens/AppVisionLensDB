CREATE TABLE [CS].[LookUp] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [Description]  NVARCHAR (50) NOT NULL,
    [Category]     NVARCHAR (30) NOT NULL,
    [IsDeleted]    BIT           DEFAULT ((0)) NOT NULL,
    [CreatedBy]    NVARCHAR (10) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (10) NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

