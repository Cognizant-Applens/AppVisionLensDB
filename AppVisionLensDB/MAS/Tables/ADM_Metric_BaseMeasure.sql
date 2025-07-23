CREATE TABLE [MAS].[ADM_Metric_BaseMeasure] (
    [BaseMeasureId]        INT           IDENTITY (1, 1) NOT NULL,
    [BaseMeasureName]      VARCHAR (300) NOT NULL,
    [BaseMeasureTypeId]    INT           NULL,
    [UOMId]                INT           NULL,
    [IndicatorId]          INT           NULL,
    [IndicatorTypeId]      INT           NULL,
    [MetricId]             INT           NULL,
    [IsDeleted]            BIT           NULL,
    [CreatedBy]            NVARCHAR (50) NULL,
    [CreatedDate]          DATETIME      NULL,
    [ModifiedBy]           NVARCHAR (50) NULL,
    [ModifiedDate]         DATETIME      NULL,
    [BaseMeasureComputeBy] INT           NULL,
    [ComputeMethodKey]     VARCHAR (200) NULL,
    CONSTRAINT [PK_MAS.ADM_MS_BaseMeasure] PRIMARY KEY CLUSTERED ([BaseMeasureId] ASC),
    CONSTRAINT [FK_BaseMeasureTypeId] FOREIGN KEY ([BaseMeasureTypeId]) REFERENCES [MAS].[ADM_MetricMaster] ([MetricMasterId]),
    CONSTRAINT [FK_GroupBy] FOREIGN KEY ([BaseMeasureComputeBy]) REFERENCES [MAS].[ADM_MetricMaster] ([MetricMasterId]),
    CONSTRAINT [FK_IndicatorId] FOREIGN KEY ([IndicatorId]) REFERENCES [MAS].[ADM_MetricMaster] ([MetricMasterId]),
    CONSTRAINT [FK_IndicatorTypeId] FOREIGN KEY ([IndicatorTypeId]) REFERENCES [MAS].[ADM_MetricMaster] ([MetricMasterId]),
    CONSTRAINT [FK_MetricId] FOREIGN KEY ([MetricId]) REFERENCES [MAS].[ADM_Metric] ([MetricId]),
    CONSTRAINT [FK_UOMId] FOREIGN KEY ([UOMId]) REFERENCES [MAS].[ADM_Metric_UOM] ([UOMId])
);

