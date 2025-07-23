CREATE TABLE [ADM].[MethodologyMetric_Mapping] (
    [ExecMetricMappingId] INT           IDENTITY (1, 1) NOT NULL,
    [MethodologyTypeId]   INT           NOT NULL,
    [MetricId]            INT           NOT NULL,
    [IsDeleted]           BIT           NULL,
    [CreatedBy]           NVARCHAR (50) NULL,
    [CreatedDate]         DATETIME      NULL,
    [ModifiedBy]          NVARCHAR (50) NULL,
    [ModifiedDate]        DATETIME      NULL,
    CONSTRAINT [PK_ADM.MS_MethodologyMetric_Mapping] PRIMARY KEY CLUSTERED ([ExecMetricMappingId] ASC),
    CONSTRAINT [FK_MethodologyTypeId] FOREIGN KEY ([MethodologyTypeId]) REFERENCES [MAS].[PPAttributeValues] ([AttributeValueID]),
    CONSTRAINT [FK_MetricId] FOREIGN KEY ([MetricId]) REFERENCES [MAS].[ADM_Metric] ([MetricId])
);

