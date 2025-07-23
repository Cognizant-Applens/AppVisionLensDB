CREATE TYPE [AVL].[TVP_BMAnalysis] AS TABLE (
    [Analysis_Id]    BIGINT NOT NULL,
    [Start_date]     DATE   NULL,
    [End_date]       DATE   NULL,
    [Effective_date] DATE   NULL,
    [Status]         INT    NULL,
    [IsBenchmark]    BIT    NULL);

