CREATE TABLE [BM].[Percentile_values] (
    [Analysis_Bench_Id] BIGINT          NOT NULL,
    [Service_level]     VARCHAR (255)   NOT NULL,
    [Service_Id]        INT             NULL,
    [P10]               DECIMAL (18, 2) NULL,
    [p20]               DECIMAL (18, 2) NULL,
    [P30]               DECIMAL (18, 2) NULL,
    [p40]               DECIMAL (18, 2) NULL,
    [P50]               DECIMAL (18, 2) NULL,
    [p60]               DECIMAL (18, 2) NULL,
    [P70]               DECIMAL (18, 2) NULL,
    [p80]               DECIMAL (18, 2) NULL,
    [P90]               DECIMAL (18, 2) NULL,
    [p100]              DECIMAL (18, 2) NULL
);

