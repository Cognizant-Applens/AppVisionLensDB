CREATE TYPE [dbo].[TVP_ISpaceOpportunityDetails] AS TABLE (
    [Id]                   INT           NOT NULL,
    [Status]               VARCHAR (100) NULL,
    [ISpaceOpportunityId]  INT           NULL,
    [ApplensOpportunityId] BIGINT        NULL,
    [CreatedDate]          DATETIME      NULL,
    [ModifiedDate]         DATETIME      NULL);

