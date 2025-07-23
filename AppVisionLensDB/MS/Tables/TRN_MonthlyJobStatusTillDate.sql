CREATE TABLE [MS].[TRN_MonthlyJobStatusTillDate] (
    [JobID]                   BIGINT       IDENTITY (1, 1) NOT NULL,
    [FrequencyID]             INT          NOT NULL,
    [ReportingPeriod]         INT          NOT NULL,
    [ReportingPeriodDESC]     VARCHAR (50) NULL,
    [JobStatus]               INT          NULL,
    [StartTime]               DATETIME     NULL,
    [EndTime]                 DATETIME     NULL,
    [NumberodrecordsAffected] INT          NULL,
    [CreatedDate]             DATETIME     NULL,
    [ModifiedDate]            DATETIME     NULL,
    CONSTRAINT [PK_Mainspriing_MonthlyJobStatusTillDate] PRIMARY KEY CLUSTERED ([JobID] ASC) WITH (FILLFACTOR = 70)
);

