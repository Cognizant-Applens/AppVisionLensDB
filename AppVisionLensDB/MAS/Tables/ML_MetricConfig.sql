CREATE TABLE [MAS].[ML_MetricConfig] (
    [MetricId]     SMALLINT      IDENTITY (1, 1) NOT NULL,
    [MetricName]   NVARCHAR (50) NOT NULL,
    [MetricKey]    NVARCHAR (6)  NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([MetricId] ASC)
);

