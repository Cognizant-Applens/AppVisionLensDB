CREATE TABLE [AVL].[InfraHierarchySixMaster] (
    [HierarchySixMasterID] INT           IDENTITY (1, 1) NOT NULL,
    [HierarchyName]        NVARCHAR (50) NOT NULL,
    [IsDeleted]            BIT           DEFAULT ((0)) NOT NULL,
    [CreatedBy]            NVARCHAR (10) NOT NULL,
    [CreatedDate]          DATETIME      DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]           NVARCHAR (10) NULL,
    [ModifiedDate]         DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([HierarchySixMasterID] ASC)
);

