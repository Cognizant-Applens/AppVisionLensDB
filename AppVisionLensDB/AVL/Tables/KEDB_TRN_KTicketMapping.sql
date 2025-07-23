CREATE TABLE [AVL].[KEDB_TRN_KTicketMapping] (
    [MappingId]  BIGINT        IDENTITY (1, 1) NOT NULL,
    [KTicketId]  NVARCHAR (50) NULL,
    [KATicketId] NVARCHAR (50) NULL,
    [IsMapped]   BIT           NULL,
    [IsDeleted]  BIT           NULL,
    [CreatedBy]  NVARCHAR (50) NULL,
    [CreatedOn]  DATETIME      NULL,
    [ModifiedBy] NVARCHAR (50) NULL,
    [ModifiedOn] DATETIME      NULL,
    [ProjectId]  BIGINT        NULL,
    CONSTRAINT [PK_KEDB_TRN_TRN_KTicketMapping] PRIMARY KEY CLUSTERED ([MappingId] ASC)
);

