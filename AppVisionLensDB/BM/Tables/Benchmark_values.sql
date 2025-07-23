CREATE TABLE [BM].[Benchmark_values] (
    [Analysis_Bench_Id] BIGINT          NOT NULL,
    [Service_level]     VARCHAR (255)   NULL,
    [Service_Id]        INT             NULL,
    [Value]             DECIMAL (18, 2) NULL,
    [Created_by]        VARCHAR (255)   NULL,
    [Created_date]      SMALLDATETIME   NULL,
    [Status]            INT             NULL
);

