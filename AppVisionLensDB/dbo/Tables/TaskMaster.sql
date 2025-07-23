CREATE TABLE [dbo].[TaskMaster] (
    [TaskName]     VARCHAR (MAX) NULL,
    [Icon]         VARCHAR (MAX) NULL,
    [Description]  VARCHAR (MAX) NULL,
    [Application]  VARCHAR (MAX) NULL,
    [RunFrequency] VARCHAR (MAX) NULL,
    [CreatedBy]    INT           NULL,
    [CreatedTime]  DATETIME      NULL,
    [ModifiedBy]   INT           NULL,
    [ModifiedTime] DATETIME      NULL,
    [TaskID]       INT           NOT NULL,
    CONSTRAINT [PK_TaskMaster] PRIMARY KEY CLUSTERED ([TaskID] ASC)
);

