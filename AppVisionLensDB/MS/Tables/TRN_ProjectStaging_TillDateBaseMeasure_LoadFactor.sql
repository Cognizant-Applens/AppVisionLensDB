CREATE TABLE [MS].[TRN_ProjectStaging_TillDateBaseMeasure_LoadFactor] (
    [ProjectStageID]   BIGINT          NOT NULL,
    [UniqueName]       NVARCHAR (2000) NOT NULL,
    [FrequencyID]      INT             NOT NULL,
    [ReportPeriodID]   INT             NOT NULL,
    [BaseMeasureValue] NVARCHAR (50)   NOT NULL,
    [UpdatedDate]      DATETIME        NULL,
    [JobID]            BIGINT          NULL,
    [MetricStartDate]  DATETIME        NULL,
    [MetricEndDate]    DATETIME        NULL
);

