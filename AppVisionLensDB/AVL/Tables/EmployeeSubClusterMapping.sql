CREATE TABLE [AVL].[EmployeeSubClusterMapping] (
    [Id]                        INT          IDENTITY (1, 1) NOT NULL,
    [EmployeeID]                VARCHAR (50) NULL,
    [CustomerID]                VARCHAR (50) NULL,
    [EmployeeCustomerMappingId] INT          NULL,
    [SubClusterId]              INT          NULL,
    [CreatedBy]                 VARCHAR (50) NULL,
    [CreatedOn]                 DATETIME     CONSTRAINT [DF_Table_2_CreatedDate] DEFAULT (getdate()) NULL,
    [ModifiedBy]                VARCHAR (50) NULL,
    [ModifiedOn]                DATETIME     NULL,
    CONSTRAINT [PK_EmployeeSubClusterMapping] PRIMARY KEY CLUSTERED ([Id] ASC)
);

