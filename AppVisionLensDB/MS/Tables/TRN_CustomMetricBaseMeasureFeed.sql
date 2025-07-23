CREATE TABLE [MS].[TRN_CustomMetricBaseMeasureFeed] (
    [ID]                INT             NOT NULL,
    [UniqueID]          NVARCHAR (2000) NULL,
    [ESAProjectID]      NVARCHAR (50)   NULL,
    [CustomMetricID]    INT             NULL,
    [BaseMeasureName]   NVARCHAR (100)  NULL,
    [BaseMeasureValue]  NVARCHAR (100)  NULL,
    [ReportPeriodID]    NVARCHAR (50)   NULL,
    [FrequencyID]       INT             NULL,
    [ReportStartDate]   DATETIME        NULL,
    [ReportEndDate]     DATETIME        NULL,
    [ReportComutedDate] DATETIME        NULL,
    [CreatedBy]         INT             NULL,
    [CreatedDate]       DATETIME        NULL,
    [ModifiedBy]        INT             NULL,
    [ModifiedDate]      DATETIME        NULL,
    CONSTRAINT [PK_CustomMetricBaseMeasureFeed] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);

