CREATE TABLE [BOT].[BotTargetApplicationMapping] (
    [Id]                     BIGINT        IDENTITY (1, 1) NOT NULL,
    [BotId]                  BIGINT        NOT NULL,
    [BotTargetApplicationId] BIGINT        NOT NULL,
    [IsDeleted]              BIT           NOT NULL,
    [CreatedBy]              NVARCHAR (50) NOT NULL,
    [CreatedDate]            DATETIME      NOT NULL,
    [ModifiedBy]             NVARCHAR (50) NULL,
    [ModifiedDate]           DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

