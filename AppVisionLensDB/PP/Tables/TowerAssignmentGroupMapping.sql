CREATE TABLE [PP].[TowerAssignmentGroupMapping] (
    [Id]                   BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectId]            BIGINT        NOT NULL,
    [AssignmentGroupMapId] BIGINT        NOT NULL,
    [TowerId]              BIGINT        NOT NULL,
    [IsDeleted]            BIT           NOT NULL,
    [CreatedBy]            NVARCHAR (50) NOT NULL,
    [CreatedDate]          DATETIME      NOT NULL,
    [ModifiedBy]           NVARCHAR (50) NULL,
    [ModifiedDate]         DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([AssignmentGroupMapId]) REFERENCES [AVL].[BOTAssignmentGroupMapping] ([AssignmentGroupMapID]),
    FOREIGN KEY ([ProjectId]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    FOREIGN KEY ([TowerId]) REFERENCES [AVL].[InfraTowerDetailsTransaction] ([InfraTowerTransactionID])
);

