CREATE TABLE [AVL].[EmployeeScreenMapping] (
    [Id]                        INT          IDENTITY (1, 1) NOT NULL,
    [EmployeeID]                VARCHAR (50) NULL,
    [CustomerID]                VARCHAR (50) NULL,
    [EmployeeCustomerMappingId] INT          NULL,
    [ScreenId]                  INT          NULL,
    [RoleId]                    INT          NULL,
    [AccessRead]                BIT          NULL,
    [AccessWrite]               BIT          NULL,
    CONSTRAINT [PK_EmployeeScreenMapping] PRIMARY KEY CLUSTERED ([Id] ASC)
);

