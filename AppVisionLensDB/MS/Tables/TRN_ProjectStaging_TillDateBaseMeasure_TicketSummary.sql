CREATE TABLE [MS].[TRN_ProjectStaging_TillDateBaseMeasure_TicketSummary] (
    [ProjectStageID]     BIGINT          NOT NULL,
    [UniqueName]         NVARCHAR (2000) NOT NULL,
    [FrequencyID]        INT             NOT NULL,
    [ReportPeriodID]     INT             NOT NULL,
    [TicketSummaryValue] NVARCHAR (50)   NOT NULL,
    [UpdatedDate]        DATETIME        NULL,
    [JobID]              BIGINT          NULL,
    [MetricStartDate]    DATETIME        NULL,
    [MetricEndDate]      DATETIME        NULL,
    CONSTRAINT [PK_ProjectStaging_TillDateBaseMeasure_TicketSummary] PRIMARY KEY CLUSTERED ([ProjectStageID] ASC, [FrequencyID] ASC, [ReportPeriodID] ASC) WITH (FILLFACTOR = 70)
);
GO