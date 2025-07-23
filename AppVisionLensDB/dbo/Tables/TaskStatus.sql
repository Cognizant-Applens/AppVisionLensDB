CREATE TABLE [dbo].[TaskStatus] (
    [TaskStatusID] INT           IDENTITY (1, 1) NOT NULL,
    [Status]       VARCHAR (200) NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    VARCHAR (50)  NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   VARCHAR (50)  NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([TaskStatusID] ASC)
);

