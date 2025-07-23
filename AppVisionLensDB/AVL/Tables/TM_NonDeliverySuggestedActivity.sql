CREATE TABLE [AVL].[TM_NonDeliverySuggestedActivity] (
    [SuggestedActivityID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]             BIGINT        NOT NULL,
    [SuggestedActivityName] NVARCHAR (50) NOT NULL,
    [IsReviewed]            BIT           NOT NULL,
    [IsDeleted]             BIT           NOT NULL,
    [CreatedBy]             NVARCHAR (50) NOT NULL,
    [CreatedDateTime]       DATETIME      NOT NULL,
    [ModifiedBy]            NVARCHAR (50) NULL,
    [ModifiedDateTime]      DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([SuggestedActivityID] ASC),
    FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);


GO
CREATE NONCLUSTERED INDEX [NCI_NonDeliverySuggestedActivity_ProjectID_SuggestedActivityName_IsDeleted]
    ON [AVL].[TM_NonDeliverySuggestedActivity]([ProjectID] ASC, [SuggestedActivityName] ASC, [IsDeleted] ASC);

