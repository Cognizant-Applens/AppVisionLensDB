CREATE TABLE [BOT].[RecommendationDetails] (
    [Id]               BIGINT         IDENTITY (1, 1) NOT NULL,
    [BotID]            NVARCHAR (MAX) NULL,
    [ProjectID]        NVARCHAR (200) NULL,
    [HealingTicketID]  NVARCHAR (200) NULL,
    [ChildTicketID]    NVARCHAR (200) NULL,
    [UseCaseID]        NVARCHAR (MAX) NULL,
    [SimilarityScore]  FLOAT (53)     NULL,
    [Category]         NVARCHAR (50)  NULL,
    [BOTSolutionMapID] NVARCHAR (100) NULL,
    [IsMapped]         BIT            NULL,
    [IsDeleted]        BIT            NULL,
    [CreatedBy]        NVARCHAR (50)  DEFAULT ('System') NULL,
    [CreatedDate]      DATETIME       DEFAULT (getdate()) NULL,
    [ModifiedBy]       NVARCHAR (50)  NULL,
    [ModifiedDate]     DATETIME       NULL,
    CONSTRAINT [PK_RecommendationDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);

