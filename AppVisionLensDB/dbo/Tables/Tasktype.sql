CREATE TABLE [dbo].[Tasktype] (
    [TaskTypeID]   INT           IDENTITY (1, 1) NOT NULL,
    [TaskType]     VARCHAR (200) NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    VARCHAR (50)  NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   VARCHAR (50)  NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([TaskTypeID] ASC)
);

