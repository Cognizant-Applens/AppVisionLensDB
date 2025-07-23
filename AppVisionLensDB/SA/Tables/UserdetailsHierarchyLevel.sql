CREATE TABLE [SA].[UserdetailsHierarchyLevel] (
    [UserDetailsHierrarchyID] INT IDENTITY (1, 1) NOT NULL,
    [UserDetailsID]           INT NOT NULL,
    [HierarchyID]             INT NOT NULL,
    PRIMARY KEY CLUSTERED ([UserDetailsHierrarchyID] ASC)
);

