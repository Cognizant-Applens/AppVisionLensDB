CREATE TABLE [AVL].[KEDB_TRN_KAUploadedFileDetails] (
    [KAUploadID] BIGINT         IDENTITY (1, 1) NOT NULL,
    [KAId]       BIGINT         NULL,
    [FileName]   NVARCHAR (MAX) NULL,
    [IsDeleted]  BIT            NULL,
    [CreatedBy]  VARCHAR (50)   NULL,
    [CreatedOn]  DATETIME       NULL,
    [ModifiedBy] VARCHAR (50)   NULL,
    [ModifiedOn] DATETIME       NULL,
    CONSTRAINT [PK_KEDB_TRN_KAUploadedFileDetails] PRIMARY KEY CLUSTERED ([KAUploadID] ASC),
    CONSTRAINT [FK__KEDB_TRN_Upload__KAId] FOREIGN KEY ([KAId]) REFERENCES [AVL].[KEDB_TRN_KATicketDetails] ([KAId])
);

