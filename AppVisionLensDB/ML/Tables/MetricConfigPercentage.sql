CREATE TABLE [ML].[MetricConfigPercentage] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [MetricKey]    NVARCHAR (30) NOT NULL,
    [MetricName]   NVARCHAR (50) NULL,
    [PercentFrom]  INT           NULL,
    [PercentTo]    INT           NULL,
    [ColorCode]    NVARCHAR (30) NULL,
    [CreatedBy]    NVARCHAR (30) NULL,
    [CreatedDate]  DATETIME      NULL,
    [ModifiedBy]   NVARCHAR (30) NULL,
    [ModifiedDate] DATETIME      NULL
);

