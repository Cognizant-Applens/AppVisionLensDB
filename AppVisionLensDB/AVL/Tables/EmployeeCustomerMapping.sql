CREATE TABLE [AVL].[EmployeeCustomerMapping] (
    [Id]         INT          IDENTITY (1, 1) NOT NULL,
    [EmployeeId] VARCHAR (50) NOT NULL,
    [CustomerId] VARCHAR (50) NOT NULL,
    [CreatedBy]  VARCHAR (50) NULL,
    [CreatedOn]  DATETIME     NULL,
    [ModifiedBy] VARCHAR (50) NULL,
    [ModifiedOn] DATETIME     NULL,
    CONSTRAINT [PK_EmployeeCustomerMapping] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20180813-202442]
    ON [AVL].[EmployeeCustomerMapping]([Id] ASC, [EmployeeId] ASC, [CustomerId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_EmployeeCustomerMapping_EmployeeID]
    ON [AVL].[EmployeeCustomerMapping]([EmployeeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_EmployeeCustomerMapping_EmployeeId_Id_CustomerId]
    ON [AVL].[EmployeeCustomerMapping]([EmployeeId] ASC)
    INCLUDE([Id], [CustomerId]);

