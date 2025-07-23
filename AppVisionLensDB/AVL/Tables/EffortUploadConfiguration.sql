CREATE TABLE [AVL].[EffortUploadConfiguration] (
    [ID]               BIGINT          IDENTITY (1, 1) NOT NULL,
    [ProjectID]        BIGINT          NULL,
    [SharePathName]    NVARCHAR (1000) NULL,
    [EffortUploadType] CHAR (1)        NULL,
    [IsMailEnabled]    CHAR (1)        NULL,
    [IsActive]         BIT             NULL,
    [CreatedBy]        NVARCHAR (500)  NULL,
    [CreatedDate]      DATETIME        NULL,
    [ModifiedBy]       NVARCHAR (500)  NULL,
    [ModifiedDate]     DATETIME        NULL
);

