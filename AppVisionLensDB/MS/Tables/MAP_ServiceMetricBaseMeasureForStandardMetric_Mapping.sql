CREATE TABLE [MS].[MAP_ServiceMetricBaseMeasureForStandardMetric_Mapping] (
    [ServiceMetricBaseMeasureMapID] BIGINT IDENTITY (1, 1) NOT NULL,
    [ServiceID]                     INT    NOT NULL,
    [MetricID]                      INT    NOT NULL,
    [BaseMeasureID]                 INT    NOT NULL,
    [PositionID]                    INT    NULL,
    [ServicewiseBasemeasureTypeID]  INT    NULL,
    [IsDeleted]                     BIT    NULL,
    CONSTRAINT [PK_ServiceMetricBaseMeasure_Mapping] PRIMARY KEY CLUSTERED ([ServiceMetricBaseMeasureMapID] ASC) WITH (FILLFACTOR = 70)
);

