CREATE TABLE [AVL].[Debt_TRN_DDExcelUploadDetails] (
    [DDUploadID]       BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]        BIGINT         NULL,
    [UploadedBy]       NVARCHAR (100) NULL,
    [UploadedFileName] NVARCHAR (MAX) NULL,
    [IsDeleted]        INT            NULL,
    [CreatedBy]        NVARCHAR (50)  NULL,
    [CreatedOn]        DATETIME       NULL,
    [ModifiedBy]       NVARCHAR (50)  NULL,
    [ModifiedOn]       DATETIME       NULL
);

