CREATE TABLE [MS].[TRN_CustomMetricOutput] (
    [ID]                INT             IDENTITY (1, 1) NOT NULL,
    [UniqueID]          NVARCHAR (2000) NULL,
    [ESAProjectID]      NVARCHAR (50)   NULL,
    [CustomMetricID]    INT             NULL,
    [CustomValue]       NVARCHAR (100)  NULL,
    [ReportPeriodID]    NVARCHAR (50)   NULL,
    [FrequencyID]       INT             NULL,
    [ReportStartDate]   DATETIME        NULL,
    [ReportEndDate]     DATETIME        NULL,
    [ReportComutedDate] DATETIME        NULL,
    [CreatedBy]         INT             NULL,
    [CreatedDate]       DATETIME        NULL,
    [ModifiedBy]        INT             NULL,
    [ModifiedDate]      DATETIME        NULL,
    CONSTRAINT [PK_CustomMetricOutput] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);

