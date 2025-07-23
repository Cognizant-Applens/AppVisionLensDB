CREATE TABLE [BM].[Analysis] (
    [Analysis_Id]    BIGINT        NOT NULL,
    [Analysis_name]  VARCHAR (255) NULL,
    [Remarks]        VARCHAR (255) NULL,
    [User_Id]        VARCHAR (255) NULL,
    [IsBenchmark]    BIT           NULL,
    [Start_date]     DATE          NULL,
    [End_date]       DATE          NULL,
    [Role]           VARCHAR (255) NULL,
    [Created_date]   SMALLDATETIME NULL,
    [Effective_date] DATE          NULL,
    [Status]         INT           NULL,
    [Modified_by]    VARCHAR (255) NULL,
    [Modified_date]  SMALLDATETIME NULL
);

