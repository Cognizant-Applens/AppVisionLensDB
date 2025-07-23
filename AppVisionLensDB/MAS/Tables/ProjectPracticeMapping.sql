CREATE TABLE [MAS].[ProjectPracticeMapping] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [ProjectID]    BIGINT        NOT NULL,
    [PracticeID]   INT           NOT NULL,
    [IsDeleted]    BIT           CONSTRAINT [DF__ProjectPr__IsDel__4D795014] DEFAULT ((0)) NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    CONSTRAINT [PK__ProjectPracticeMapping] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK__ProjectPracticeMapping_Practice] FOREIGN KEY ([PracticeID]) REFERENCES [MAS].[Practices] ([PracticeID]),
    CONSTRAINT [FK_ProjectPracticeMapping_MAS_ProjectMaster] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_ProjectPracticeMapping]
    ON [MAS].[ProjectPracticeMapping]([IsDeleted] ASC)
    INCLUDE([PracticeID], [ProjectID]);


GO
CREATE NONCLUSTERED INDEX [IDX_ProjectPracticeMapping_ProjectID_IsDeleted]
    ON [MAS].[ProjectPracticeMapping]([ProjectID] ASC, [IsDeleted] ASC);

