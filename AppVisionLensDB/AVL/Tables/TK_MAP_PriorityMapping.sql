CREATE TABLE [AVL].[TK_MAP_PriorityMapping] (
    [PriorityIDMapID]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [PriorityID]                  BIGINT        NULL,
    [PriorityName]                VARCHAR (500) NULL,
    [ProjectID]                   BIGINT        NOT NULL,
    [IsDeleted]                   CHAR (1)      NULL,
    [CreatedDateTime]             DATETIME      NULL,
    [CreatedBY]                   NVARCHAR (50) NULL,
    [ModifiedDateTime]            DATETIME      NULL,
    [ModifiedBY]                  NVARCHAR (50) NULL,
    [POSITION]                    INT           NULL,
    [IsDefaultPriority]           NVARCHAR (50) NULL,
    [MainspringProjectPriorityID] INT           NULL,
    CONSTRAINT [PK_TK_MAP_PriorityMapping] PRIMARY KEY CLUSTERED ([PriorityIDMapID] ASC),
    CONSTRAINT [FK_TK_MAP_PriorityMapping_MAS_ProjectMaster] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    CONSTRAINT [FK_TK_MAP_PriorityMapping_TK_MAS_Priority] FOREIGN KEY ([PriorityID]) REFERENCES [AVL].[TK_MAS_Priority] ([PriorityID])
);


GO
CREATE NONCLUSTERED INDEX [NIXK3_TK_MAP_PriorityMapping_ProjectID]
    ON [AVL].[TK_MAP_PriorityMapping]([ProjectID] ASC);

