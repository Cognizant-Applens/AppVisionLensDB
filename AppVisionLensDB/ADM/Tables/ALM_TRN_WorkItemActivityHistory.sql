CREATE TABLE [ADM].[ALM_TRN_WorkItemActivityHistory] (
    [WorkItemActivityHistoryId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [WorkItemDetailsId]         BIGINT        NOT NULL,
    [AttributeName]             VARCHAR (50)  NOT NULL,
    [PreviousValue]             VARCHAR (100) NULL,
    [CurrentValue]              VARCHAR (100) NULL,
    [ModifiedDate]              DATETIME      NULL,
    [ModifiedBy]                NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([WorkItemActivityHistoryId] ASC)
);

