CREATE TABLE [AVL].[MAS_AssignmentGroupType] (
    [AssignmentGroupTypeID]   INT           IDENTITY (1, 1) NOT NULL,
    [AssignmentGroupTypeName] NVARCHAR (50) NULL,
    [IsDeleted]               BIT           NULL,
    [CreatedBy]               NVARCHAR (50) NULL,
    [CreatedDate]             DATETIME      NULL,
    [ModifiedBy]              NVARCHAR (50) NULL,
    [ModifiedDate]            DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([AssignmentGroupTypeID] ASC)
);

