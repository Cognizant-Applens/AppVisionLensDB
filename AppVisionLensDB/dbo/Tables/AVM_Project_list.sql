CREATE TABLE [dbo].[AVM_Project_list] (
    [ESAProjectID]    BIGINT        NOT NULL,
    [PracticeOwnerId] BIGINT        NOT NULL,
    [DEScopeId]       INT           NULL,
    [ISDeleted]       BIT           NULL,
    [CreatedBy]       NVARCHAR (50) NOT NULL,
    [CreatedDate]     DATETIME      NOT NULL,
    [ModifiedBy]      NVARCHAR (50) NULL,
    [ModifiedDate]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ESAProjectID] ASC),
    FOREIGN KEY ([DEScopeId]) REFERENCES [dbo].[DEScopeStatusMaster] ([ID]),
    FOREIGN KEY ([PracticeOwnerId]) REFERENCES [AVL].[BusinessUnit] ([BUID])
);

