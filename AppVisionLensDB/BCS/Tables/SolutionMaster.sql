CREATE TABLE [BCS].[SolutionMaster] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [SolutionName] NVARCHAR (100) NOT NULL,
    [IsDeleted]    BIT            DEFAULT ((0)) NOT NULL,
    [CreatedBy]    NVARCHAR (50)  DEFAULT ('SYSTEM') NOT NULL,
    [CreatedDate]  DATETIME       DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  DEFAULT ('SYSTEM') NULL,
    [ModifiedDate] DATETIME       DEFAULT (getdate()) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

