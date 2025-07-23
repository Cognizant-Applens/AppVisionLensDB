CREATE TABLE [MAS].[JobStatus] (
    [ID]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [JobId]               BIGINT          NOT NULL,
    [StartDateTime]       DATETIME        NOT NULL,
    [EndDateTime]         DATETIME        NOT NULL,
    [JobStatus]           NVARCHAR (50)   NOT NULL,
    [Remarks]             NVARCHAR (2000) NULL,
    [JobRunDate]          DATETIME        NOT NULL,
    [InsertedRecordCount] BIGINT          NULL,
    [DeletedRecordCount]  BIGINT          NULL,
    [UpdatedRecordCount]  BIGINT          NULL,
    [IsDeleted]           BIT             NOT NULL,
    [CreatedBy]           NVARCHAR (50)   NOT NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    FOREIGN KEY ([JobId]) REFERENCES [MAS].[JobMaster] ([JobID])
);

