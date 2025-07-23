CREATE TABLE [BOT].[RecommendedRatings] (
    [BotRatingId]     BIGINT         IDENTITY (1, 1) NOT NULL,
    [EmployeeID]      NVARCHAR (50)  NULL,
    [HealingTicketID] NVARCHAR (100) NULL,
    [Rating]          INT            NULL,
    [BotId]           BIGINT         NOT NULL,
    [IsDeleted]       BIT            NULL,
    [CreatedBy]       NVARCHAR (50)  NULL,
    [CreatedOn]       DATETIME       NULL,
    [ModifiedBy]      NVARCHAR (50)  NULL,
    [ModifiedOn]      DATETIME       NULL,
    CONSTRAINT [PK_RecommendedRatings] PRIMARY KEY CLUSTERED ([BotRatingId] ASC),
    CONSTRAINT [FK_RecommendedRatings_MasterRepository] FOREIGN KEY ([BotId]) REFERENCES [BOT].[MasterRepository] ([Id])
);

