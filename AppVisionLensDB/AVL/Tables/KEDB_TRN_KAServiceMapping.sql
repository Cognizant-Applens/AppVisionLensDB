CREATE TABLE [AVL].[KEDB_TRN_KAServiceMapping] (
    [KAService_Map_ID] BIGINT       IDENTITY (1, 1) NOT NULL,
    [KAID]             BIGINT       NULL,
    [ServiceID]        INT          NULL,
    [IsDeleted]        BIT          NULL,
    [CreatedBy]        VARCHAR (50) NULL,
    [CreatedOn]        DATETIME     NULL,
    [ModifiedBy]       VARCHAR (50) NULL,
    [ModifiedOn]       DATETIME     NULL,
    CONSTRAINT [PK_KEDB_TRN_KAServiceMapping] PRIMARY KEY CLUSTERED ([KAService_Map_ID] ASC),
    CONSTRAINT [FK_KEDB_TRN_KASM_KATicketDetails] FOREIGN KEY ([KAID]) REFERENCES [AVL].[KEDB_TRN_KATicketDetails] ([KAId]),
    CONSTRAINT [FK_KEDB_TRN_KASM_MAS_Service] FOREIGN KEY ([ServiceID]) REFERENCES [AVL].[TK_MAS_Service] ([ServiceID])
);


GO
CREATE NONCLUSTERED INDEX [NC_index_KEDB_KAService]
    ON [AVL].[KEDB_TRN_KAServiceMapping]([IsDeleted] ASC)
    INCLUDE([KAID], [ServiceID]);


GO
CREATE NONCLUSTERED INDEX [NC_KEDB_SerMap]
    ON [AVL].[KEDB_TRN_KAServiceMapping]([ServiceID] ASC, [IsDeleted] ASC)
    INCLUDE([KAID]);

