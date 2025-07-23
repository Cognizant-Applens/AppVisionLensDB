CREATE TABLE [BM].[map_AppHost] (
    [HostedEnvironment_Id] INT           NOT NULL,
    [BenchAppHostGroup_Id] INT           NOT NULL,
    [IsDeleted]            BIT           NULL,
    [CreatedBy]            VARCHAR (255) NULL,
    [CreatedDate]          SMALLDATETIME NULL
);

