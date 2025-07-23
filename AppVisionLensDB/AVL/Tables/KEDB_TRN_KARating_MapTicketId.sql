CREATE TABLE [AVL].[KEDB_TRN_KARating_MapTicketId] (
    [RatingMapId]    BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectId]      BIGINT         NOT NULL,
    [KAID]           BIGINT         NOT NULL,
    [TicketId]       NVARCHAR (50)  NULL,
    [IsLinked]       INT            NULL,
    [Rating]         INT            NULL,
    [ReviewComments] NVARCHAR (250) NULL,
    [Improvements]   NVARCHAR (250) NULL,
    [CreatedBy]      NVARCHAR (50)  NULL,
    [CreatedOn]      DATETIME       DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]     NVARCHAR (50)  NULL,
    [ModifiedOn]     DATETIME       NULL,
    [IsDeleted]      BIT            NULL,
    CONSTRAINT [PK_KEDB_TRN_KARating_MapTicketId] PRIMARY KEY CLUSTERED ([RatingMapId] ASC),
    CONSTRAINT [FK_KEDB_KAId_Rating] FOREIGN KEY ([KAID]) REFERENCES [AVL].[KEDB_TRN_KATicketDetails] ([KAId])
);

