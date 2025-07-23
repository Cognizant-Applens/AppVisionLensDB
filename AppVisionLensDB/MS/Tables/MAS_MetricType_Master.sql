CREATE TABLE [MS].[MAS_MetricType_Master] (
    [MetricTypeID]   INT           IDENTITY (1, 1) NOT NULL,
    [MetricTypeDesc] NVARCHAR (50) NULL,
    [IsDeleted]      BIT           NULL,
    CONSTRAINT [PK_MetricType_Master] PRIMARY KEY CLUSTERED ([MetricTypeID] ASC) WITH (FILLFACTOR = 70)
);

