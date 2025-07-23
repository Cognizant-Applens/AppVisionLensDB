CREATE TABLE [ADM].[ExecutionMethod] (
    [ID]                  BIGINT        IDENTITY (1, 1) NOT NULL,
    [ExecutionMethodName] VARCHAR (50)  NOT NULL,
    [IsDeleted]           BIT           NOT NULL,
    [CreatedBy]           NVARCHAR (50) NOT NULL,
    [CreatedDate]         DATETIME      NOT NULL,
    [ModifiedBy]          NVARCHAR (50) NULL,
    [ModifiedDate]        DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

