CREATE TABLE [MS].[TRN_MonthlyJobStatus] (
    [JobID]                   BIGINT        IDENTITY (1, 1) NOT NULL,
    [FrequencyID]             INT           NOT NULL,
    [ReportingPeriod]         INT           NOT NULL,
    [ReportingPeriodDESC]     NVARCHAR (50) NULL,
    [JobStatus]               INT           NULL,
    [StartTime]               DATETIME      NULL,
    [EndTime]                 DATETIME      NULL,
    [NumberodrecordsAffected] INT           NULL,
    [CreatedDate]             DATETIME      NULL,
    [ModiifiedDate]           DATETIME      NULL,
    CONSTRAINT [PK_Mainspriing_MonthlyJobStatus] PRIMARY KEY CLUSTERED ([JobID] ASC) WITH (FILLFACTOR = 70)
);

