CREATE TABLE [MAS].[ADM_Metric] (
    [MetricId]     INT           IDENTITY (1, 1) NOT NULL,
    [MetricName]   VARCHAR (100) NOT NULL,
    [MetricTypeId] INT           NOT NULL,
    [IsDeleted]    BIT           NULL,
    [CreatedBy]    NVARCHAR (50) NULL,
    [CreatedDate]  DATETIME      NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    CONSTRAINT [PK_MAS.ADM_MS_Metric] PRIMARY KEY CLUSTERED ([MetricId] ASC),
    CONSTRAINT [FK_MetricMasterId] FOREIGN KEY ([MetricTypeId]) REFERENCES [MAS].[ADM_MetricMaster] ([MetricMasterId])
);

