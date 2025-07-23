CREATE TABLE [dbo].[EffortUploadTrack] (
    [ID]                        INT            IDENTITY (1, 1) NOT NULL,
    [ProjectID]                 NVARCHAR (100) NULL,
    [EffortUploadDumpFileName]  VARCHAR (MAX)  NULL,
    [EffortUploadErrorDumpFile] VARCHAR (MAX)  NULL,
    [Status]                    CHAR (2)       NULL,
    [FilePickedTime]            DATETIME       NULL,
    [APIRequestedTime]          DATETIME       NULL,
    [APIRespondedTime]          DATETIME       NULL,
    [IsActive]                  BIT            NULL,
    [Remarks]                   VARCHAR (MAX)  NULL,
    [CreatedBy]                 NVARCHAR (100) NULL,
    [CreatedDate]               DATETIME       NULL,
    [ModifiedBy]                NVARCHAR (100) NULL,
    [ModifiedDate]              DATETIME       NULL,
    CONSTRAINT [PK_EffortUploadTrack] PRIMARY KEY CLUSTERED ([ID] ASC)
);

