CREATE TYPE [dbo].[TVP_ISpaceIdeaDetails] AS TABLE (
    [Id]              INT           NOT NULL,
    [Status]          VARCHAR (100) NULL,
    [ISpaceIdeaId]    INT           NULL,
    [ApplensTicketId] INT           NULL,
    [CreatedDate]     DATETIME      NULL,
    [ModifiedDate]    DATETIME      NULL);

