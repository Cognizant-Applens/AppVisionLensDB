CREATE TABLE [MS].[MAS_Metric_Master] (
    [MetricID]     INT            IDENTITY (1, 1) NOT NULL,
    [MetricName]   NVARCHAR (300) NULL,
    [MetricTypeID] INT            NULL,
    [UOMID]        INT            NULL,
    [FrequencyID]  INT            NULL,
    [IsDeleted]    BIT            NULL,
    CONSTRAINT [PK_Metric_Master] PRIMARY KEY CLUSTERED ([MetricID] ASC) WITH (FILLFACTOR = 70)
);

