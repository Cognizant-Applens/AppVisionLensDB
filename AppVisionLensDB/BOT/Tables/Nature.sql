CREATE TABLE [BOT].[Nature] (
    [Id]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [Nature]       NVARCHAR (50) NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    CONSTRAINT [PK_Nature] PRIMARY KEY CLUSTERED ([Id] ASC)
);

