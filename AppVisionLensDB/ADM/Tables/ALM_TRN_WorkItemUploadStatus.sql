CREATE TABLE [ADM].[ALM_TRN_WorkItemUploadStatus] (
    [LogID]             BIGINT         IDENTITY (1, 1) NOT NULL,
    [UploadedFileName]  NVARCHAR (100) NULL,
    [ProjectID]         BIGINT         NULL,
    [UploadMode]        NVARCHAR (50)  NULL,
    [TemplateType]      NVARCHAR (50)  NULL,
    [TotalWorkItems]    INT            NULL,
    [UploadedStartTime] DATETIME       NULL,
    [UploadedEndTime]   DATETIME       NULL,
    [Status]            NVARCHAR (50)  NULL,
    [ErrorFileName]     NVARCHAR (100) NULL,
    [CreatedBy]         NVARCHAR (50)  NOT NULL,
    [CreatedDate]       DATETIME       NOT NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL,
    [ModifiedDate]      DATETIME       NULL,
    CONSTRAINT [PK_ALM_TRN_WorkItemUploadStatus] PRIMARY KEY CLUSTERED ([LogID] ASC)
);

