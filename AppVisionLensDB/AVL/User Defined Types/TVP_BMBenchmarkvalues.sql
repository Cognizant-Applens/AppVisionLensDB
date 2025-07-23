CREATE TYPE [AVL].[TVP_BMBenchmarkvalues] AS TABLE (
    [Analysis_Bench_Id] BIGINT          NOT NULL,
    [Service_level]     VARCHAR (255)   NULL,
    [Service_Id]        INT             NULL,
    [Value]             DECIMAL (18, 2) NULL,
    [Status]            INT             NULL);

