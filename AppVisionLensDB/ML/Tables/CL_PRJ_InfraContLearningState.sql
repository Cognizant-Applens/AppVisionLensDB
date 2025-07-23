CREATE TABLE [ML].[CL_PRJ_InfraContLearningState] (
    [ProjectJobID]   BIGINT        NULL,
    [ContLearningID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]      BIGINT        NOT NULL,
    [PresentStatus]  INT           NULL,
    [SentBy]         NVARCHAR (50) NULL,
    [SentOn]         DATETIME      NULL,
    [ReceivedBy]     NVARCHAR (50) NULL,
    [ReceivedOn]     DATETIME      NULL,
    [IsSDTicket]     BIT           NULL,
    [IsDARTTicket]   BIT           NULL,
    [CreatedBy]      NVARCHAR (50) NOT NULL,
    [CreatedDate]    DATETIME      NOT NULL,
    [ModifiedBy]     NVARCHAR (50) NULL,
    [ModifiedDate]   DATETIME      NULL,
    [IsDeleted]      BIT           NOT NULL,
    PRIMARY KEY CLUSTERED ([ContLearningID] ASC),
    CONSTRAINT [FK_CL_PRJ_InfraContLearningState_CL_InfraProjectJobDetails] FOREIGN KEY ([ProjectJobID]) REFERENCES [ML].[CL_InfraProjectJobDetails] ([ID]),
    CONSTRAINT [FK_InfraStateProjectID] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

