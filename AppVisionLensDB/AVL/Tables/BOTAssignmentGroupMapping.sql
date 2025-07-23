CREATE TABLE [AVL].[BOTAssignmentGroupMapping] (
    [AssignmentGroupMapID]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]                     BIGINT         NOT NULL,
    [AssignmentGroupName]           NVARCHAR (200) NULL,
    [AssignmentGroupCategoryTypeID] INT            NULL,
    [SupportTypeID]                 INT            NOT NULL,
    [IsBOTGroup]                    BIT            NULL,
    [IsDeleted]                     BIT            NULL,
    [CreatedBy]                     NVARCHAR (50)  NULL,
    [CreatedDate]                   DATETIME       NULL,
    [ModifiedBy]                    NVARCHAR (50)  NULL,
    [ModifiedDate]                  DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([AssignmentGroupMapID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [BOTAssignmentGroupMapping_ProjectId]
    ON [AVL].[BOTAssignmentGroupMapping]([ProjectID] ASC)
    INCLUDE([AssignmentGroupName], [AssignmentGroupCategoryTypeID], [IsBOTGroup], [IsDeleted]);


GO
CREATE NONCLUSTERED INDEX [NCI_BOTAssignmentGroupMapping_ProjectId_AGC_IBG_ID]
    ON [AVL].[BOTAssignmentGroupMapping]([ProjectID] ASC, [AssignmentGroupCategoryTypeID] ASC, [IsBOTGroup] ASC, [IsDeleted] ASC);

