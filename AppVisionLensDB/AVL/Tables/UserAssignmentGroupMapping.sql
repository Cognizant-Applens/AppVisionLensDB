CREATE TABLE [AVL].[UserAssignmentGroupMapping] (
    [ID]                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]            BIGINT         NOT NULL,
    [UserID]               NVARCHAR (100) NOT NULL,
    [AssignmentGroupMapID] BIGINT         NOT NULL,
    [IsDeleted]            BIT            NULL,
    [CreatedBy]            NVARCHAR (MAX) NULL,
    [CreatedDate]          DATETIME       NULL,
    [ModifiedBy]           NVARCHAR (MAX) NULL,
    [ModifiedDate]         DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    FOREIGN KEY ([AssignmentGroupMapID]) REFERENCES [AVL].[BOTAssignmentGroupMapping] ([AssignmentGroupMapID])
);


GO
CREATE NONCLUSTERED INDEX [NCI_UserAssignmentGroupMapping_ProjectID_IsDeleted]
    ON [AVL].[UserAssignmentGroupMapping]([ProjectID] ASC, [IsDeleted] ASC)
    INCLUDE([UserID], [AssignmentGroupMapID]);

