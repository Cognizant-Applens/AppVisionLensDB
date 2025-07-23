CREATE TABLE [AVL].[KEDB_TRN_KATicketActivityDetails] (
    [KAActivityID]        BIGINT          IDENTITY (1, 1) NOT NULL,
    [KAId]                BIGINT          NULL,
    [ActivityDescription] NVARCHAR (4000) NULL,
    [Effort]              DECIMAL (18)    NULL,
    [IsAutomatable]       BIT             NULL,
    [IsDeleted]           BIT             NULL,
    [CreatedBy]           VARCHAR (50)    NULL,
    [CreatedOn]           DATETIME        NULL,
    [ModifiedBy]          VARCHAR (50)    NULL,
    [ModifiedOn]          DATETIME        NULL,
    CONSTRAINT [PK_KEDB_TRN_KATicketActivityDetails] PRIMARY KEY CLUSTERED ([KAActivityID] ASC),
    CONSTRAINT [FK_KEDB_K_KAId] FOREIGN KEY ([KAId]) REFERENCES [AVL].[KEDB_TRN_KATicketDetails] ([KAId])
);


GO
CREATE NONCLUSTERED INDEX [NC_KEDB_KAID_ISdeleted]
    ON [AVL].[KEDB_TRN_KATicketActivityDetails]([IsDeleted] ASC)
    INCLUDE([KAId]);

