CREATE TABLE [BM].[Analysis_Workbench] (
    [Analysis_Bench_Id] BIGINT        NOT NULL,
    [Analysis_Id]       BIGINT        NOT NULL,
    [Parameter_Id]      INT           NOT NULL,
    [Parameter_value]   INT           NULL,
    [Detail_Id]         INT           NULL,
    [Status_Id]         INT           NULL,
    [Remarks]           VARCHAR (255) NULL,
    [Created_by]        VARCHAR (255) NULL,
    [Created_date]      SMALLDATETIME NULL,
    [Modified_by]       VARCHAR (255) NULL,
    [Modified_date]     SMALLDATETIME NULL
);

