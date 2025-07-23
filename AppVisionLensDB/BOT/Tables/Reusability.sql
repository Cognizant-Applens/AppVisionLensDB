CREATE TABLE [BOT].[Reusability] (
    [Id]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [Reusability]  NVARCHAR (50) NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    CONSTRAINT [PK_Reusability] PRIMARY KEY CLUSTERED ([Id] ASC)
);

