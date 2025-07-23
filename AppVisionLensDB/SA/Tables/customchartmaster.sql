CREATE TABLE [SA].[customchartmaster] (
    [CustomChartID] INT           NOT NULL,
    [PanelNumber]   VARCHAR (45)  NOT NULL,
    [ChartType]     VARCHAR (45)  DEFAULT (NULL) NULL,
    [ProcedureName] VARCHAR (100) DEFAULT (NULL) NULL,
    [IsEnabled]     BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([CustomChartID] ASC)
);

