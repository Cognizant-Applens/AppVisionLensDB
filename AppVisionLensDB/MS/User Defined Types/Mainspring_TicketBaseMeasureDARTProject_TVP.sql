CREATE TYPE [MS].[Mainspring_TicketBaseMeasureDARTProject_TVP] AS TABLE (
    [ProjectStageID]     BIGINT         NOT NULL,
    [UniqueName]         NVARCHAR (MAX) NOT NULL,
    [FrequencyID]        INT            NOT NULL,
    [ReportPeriodID]     INT            NOT NULL,
    [TicketSummaryValue] NVARCHAR (500) NOT NULL,
    [UpdatedDate]        DATETIME       NULL,
    [JobID]              BIGINT         NULL,
    [MetricStartDate]    DATETIME       NULL,
    [MetricEndDate]      DATETIME       NULL);

