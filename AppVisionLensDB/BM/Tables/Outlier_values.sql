CREATE TABLE [BM].[Outlier_values] (
    [Analysis_Bench_Id] BIGINT          NOT NULL,
    [Service_level]     VARCHAR (255)   NOT NULL,
    [Service_Id]        INT             NULL,
    [Min]               DECIMAL (18, 2) NULL,
    [Max]               DECIMAL (18, 2) NULL
);

