CREATE TABLE [CS].[TagOpportunity] (
    [TagId]         INT           IDENTITY (1, 1) NOT NULL,
    [OpportunityId] BIGINT        NOT NULL,
    [Tag]           NVARCHAR (25) NOT NULL,
    [IsDeleted]     BIT           DEFAULT ((0)) NOT NULL,
    [CreatedBy]     NVARCHAR (50) NOT NULL,
    [CreatedDate]   DATETIME      NOT NULL,
    [ModifiedBy]    NVARCHAR (50) NULL,
    [ModifiedDate]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([TagId] ASC),
    FOREIGN KEY ([OpportunityId]) REFERENCES [CS].[Opportunity] ([OpportunityId])
);

