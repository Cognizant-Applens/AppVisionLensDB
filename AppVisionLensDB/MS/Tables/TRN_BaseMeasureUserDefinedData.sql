CREATE TABLE [MS].[TRN_BaseMeasureUserDefinedData] (
    [ProjectID]        INT            NOT NULL,
    [ServiceID]        INT            NOT NULL,
    [BaseMeasureID]    INT            NOT NULL,
    [FrequencyID]      INT            NOT NULL,
    [ReportPeriodID]   INT            NOT NULL,
    [BaseMeasureValue] NVARCHAR (150) NOT NULL,
    [CreatedBy]        NVARCHAR (50)  NULL,
    [CreatedOn]        DATETIME       NULL,
    [ModifiedBy]       NVARCHAR (50)  NULL,
    [ModifiedOn]       DATETIME       NULL,
    CONSTRAINT [PK_BaseMeasureUserDefinedData] PRIMARY KEY CLUSTERED ([ProjectID] ASC, [ServiceID] ASC, [BaseMeasureID] ASC, [FrequencyID] ASC, [ReportPeriodID] ASC) WITH (FILLFACTOR = 70)
);

