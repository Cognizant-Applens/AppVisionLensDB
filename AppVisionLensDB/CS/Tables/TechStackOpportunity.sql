CREATE TABLE [CS].[TechStackOpportunity] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [OpportunityId] BIGINT         NOT NULL,
    [TechStack]     NVARCHAR (100) NOT NULL,
    [IsDeleted]     BIT            DEFAULT ((0)) NOT NULL,
    [CreatedBy]     NVARCHAR (50)  NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    [ModifiedDate]  DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([OpportunityId]) REFERENCES [CS].[Opportunity] ([OpportunityId]),
    UNIQUE NONCLUSTERED ([OpportunityId] ASC, [TechStack] ASC)
);

