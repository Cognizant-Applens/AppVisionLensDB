CREATE TABLE [AVL].[MyTaskAutoHealingJob] (
    [ID]              BIGINT          IDENTITY (1, 1) NOT NULL,
    [UserID]          BIGINT          NULL,
    [TaskID]          BIGINT          NULL,
    [TaskName]        NVARCHAR (1000) NOT NULL,
    [URL]             NVARCHAR (100)  NOT NULL,
    [TaskDetails]     NVARCHAR (1000) NOT NULL,
    [Application]     NVARCHAR (1000) NOT NULL,
    [Status]          VARCHAR (50)    NULL,
    [RefreshedTime]   DATETIME        NOT NULL,
    [CreatedBy]       NVARCHAR (50)   NOT NULL,
    [CreatedTime]     DATETIME        NOT NULL,
    [ModifiedBy]      NVARCHAR (50)   NULL,
    [ModifiedTime]    DATETIME        NULL,
    [TaskType]        VARCHAR (50)    NULL,
    [ExpiryDate]      DATE            NULL,
    [Duedate]         DATE            NULL,
    [Read]            CHAR (1)        NULL,
    [ExpiryAfterRead] INT             NULL,
    [AccountID]       BIGINT          NULL
);

