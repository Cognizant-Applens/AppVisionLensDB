CREATE TABLE [dbo].[TaskApplication] (
    [TaskApplicationID] INT           IDENTITY (1, 1) NOT NULL,
    [TaskID]            INT           NOT NULL,
    [ApplicationName]   VARCHAR (200) NOT NULL,
    [IsDeleted]         BIT           NOT NULL,
    [CreatedBy]         VARCHAR (50)  NOT NULL,
    [CreatedDate]       DATETIME      NOT NULL,
    [ModifiedBy]        VARCHAR (50)  NULL,
    [ModifiedDate]      DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([TaskApplicationID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_TaskID_IsDeleted]
    ON [dbo].[TaskApplication]([TaskID] ASC, [IsDeleted] ASC);

