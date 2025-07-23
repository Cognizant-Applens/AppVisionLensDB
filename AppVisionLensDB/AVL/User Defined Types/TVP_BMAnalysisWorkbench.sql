CREATE TYPE [AVL].[TVP_BMAnalysisWorkbench] AS TABLE (
    [Analysis_Bench_Id] BIGINT NOT NULL,
    [Analysis_Id]       BIGINT NOT NULL,
    [Parameter_Id]      INT    NOT NULL,
    [Parameter_value]   INT    NULL,
    [Detail_Id]         INT    NULL,
    [Status_Id]         INT    NULL);

