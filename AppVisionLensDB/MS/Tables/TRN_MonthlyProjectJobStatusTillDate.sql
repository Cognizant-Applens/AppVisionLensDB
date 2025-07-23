CREATE TABLE [MS].[TRN_MonthlyProjectJobStatusTillDate] (
    [JobID]                   BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]               INT           NOT NULL,
    [FrequencyID]             INT           NOT NULL,
    [ReportingPeriod]         INT           NOT NULL,
    [ReportingPeriodDESC]     NVARCHAR (50) NULL,
    [JobStatus]               INT           NULL,
    [StartTime]               DATETIME      NULL,
    [EndTime]                 DATETIME      NULL,
    [NumberodrecordsAffected] INT           NULL,
    CONSTRAINT [PK_Mainspriing_MonthlyProjectJobStatusTillDate] PRIMARY KEY CLUSTERED ([JobID] ASC) WITH (FILLFACTOR = 70)
);

