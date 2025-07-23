CREATE TABLE [AVL].[KEDB_TRN_KATicketLinkDetails] (
    [KALinkID]   BIGINT         IDENTITY (1, 1) NOT NULL,
    [KAId]       BIGINT         NULL,
    [Link]       NVARCHAR (MAX) NULL,
    [LinkAlias]  NVARCHAR (200) NULL,
    [IsDeleted]  BIT            NULL,
    [CreatedBy]  VARCHAR (50)   NULL,
    [CreatedOn]  DATETIME       NULL,
    [ModifiedBy] VARCHAR (50)   NULL,
    [ModifiedOn] DATETIME       NULL,
    CONSTRAINT [PK_KEDB_TRN_KATicketLinkDetails] PRIMARY KEY CLUSTERED ([KALinkID] ASC),
    CONSTRAINT [FK__KEDB_TRN_K__KAId] FOREIGN KEY ([KAId]) REFERENCES [AVL].[KEDB_TRN_KATicketDetails] ([KAId])
);

