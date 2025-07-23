CREATE TYPE [MS].[Mainspring_TicketBaseMeasureNonDARTProject_TVP] AS TABLE (
    [ProjectStageID]     BIGINT         NOT NULL,
    [UniqueName]         VARCHAR (2000) NOT NULL,
    [FrequencyID]        INT            NOT NULL,
    [ReportPeriodID]     INT            NOT NULL,
    [TicketSummaryValue] VARCHAR (50)   NOT NULL,
    [UpdatedDate]        DATETIME       NULL,
    [JobID]              BIGINT         NULL,
    [MetricStartDate]    DATETIME       NULL,
    [MetricEndDate]      DATETIME       NULL);

