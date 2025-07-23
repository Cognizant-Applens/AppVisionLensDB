CREATE TABLE [dbo].[MainspringMonthlyTrack] (
    [Id]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectId]    BIGINT        NULL,
    [MethodName]   VARCHAR (500) NULL,
    [StartTime]    VARCHAR (500) NULL,
    [EndTime]      VARCHAR (500) NULL,
    [Remarks]      VARCHAR (500) NULL,
    [CreatedBy]    VARCHAR (500) NULL,
    [CreatedDate]  DATETIME      NULL,
    [ModifiedBy]   VARCHAR (500) NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

