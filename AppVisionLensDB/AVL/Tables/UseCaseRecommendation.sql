CREATE TABLE [AVL].[UseCaseRecommendation] (
    [ID]                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [UseCaseID]            NVARCHAR (MAX) NULL,
    [SimilarityScore]      FLOAT (53)     NULL,
    [HealingTicketID]      NVARCHAR (100) NOT NULL,
    [UseCaseSolutionMapId] BIGINT         NOT NULL,
    [IsMappedSolution]     BIT            NULL,
    [IsDeleted]            BIT            NULL,
    [CreatedBy]            VARCHAR (50)   DEFAULT ('UseCaseRecommendationSystem') NULL,
    [CreatedOn]            DATETIME       DEFAULT (getdate()) NULL,
    [ModifiedBy]           VARCHAR (50)   NULL,
    [ModifiedOn]           DATETIME       NULL,
    [ProjectID]            BIGINT         NULL,
    [Category]             NVARCHAR (20)  NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

