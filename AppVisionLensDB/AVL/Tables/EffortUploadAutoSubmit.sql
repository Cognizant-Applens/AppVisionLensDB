CREATE TABLE [AVL].[EffortUploadAutoSubmit] (
    [ID]            BIGINT         IDENTITY (1, 1) NOT NULL,
    [CustomerID]    BIGINT         NULL,
    [ProjectID]     BIGINT         NULL,
    [SubmitterID]   BIGINT         NULL,
    [TimeSheetDate] DATE           NULL,
    [IsProcessed]   BIT            NULL,
    [IsDeleted]     BIT            NULL,
    [CreatedBy]     NVARCHAR (MAX) NULL,
    [CreatedDate]   DATETIME       NULL,
    [ModifiedBy]    NVARCHAR (MAX) NULL,
    [ModifiedDate]  DATETIME       NULL
);

