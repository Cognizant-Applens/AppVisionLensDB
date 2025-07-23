CREATE TABLE [AVL].[EffortUploadErrorLog] (
    [LogID]                BIGINT          IDENTITY (1, 1) NOT NULL,
    [ProjectID]            BIGINT          NULL,
    [EffortUploadDumpName] NVARCHAR (1000) NULL,
    [ErrorFileName]        NVARCHAR (1000) NULL,
    [TotalRecords]         NVARCHAR (1000) NULL,
    [SuccessCount]         BIGINT          NULL,
    [ReUploadedCount]      BIGINT          NULL,
    [FailedCount]          BIGINT          NULL,
    [UploadedEndDate]      DATETIME        NULL,
    [IsActive]             BIT             NULL,
    [CreatedBy]            NVARCHAR (500)  NULL,
    [CreatedDate]          DATETIME        NULL,
    [ModifiedBy]           NVARCHAR (500)  NULL,
    [ModifiedDate]         NVARCHAR (500)  NULL,
    [Status]               NVARCHAR (500)  NULL
);

