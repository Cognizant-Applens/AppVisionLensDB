CREATE TABLE [AVL].[EmployeeRoleMapping] (
    [Id]                        INT          IDENTITY (1, 1) NOT NULL,
    [EmployeeCustomerMappingId] INT          NOT NULL,
    [RoleId]                    INT          NULL,
    [CreatedBy]                 VARCHAR (50) NULL,
    [CreatedOn]                 DATETIME     NULL,
    [ModifiedBy]                VARCHAR (50) NULL,
    [ModifiedOn]                DATETIME     NULL,
    CONSTRAINT [PK_EmployeeRoleMapping] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_EmployeeRoleMapping_EmployeeCustomerMapping] FOREIGN KEY ([EmployeeCustomerMappingId]) REFERENCES [AVL].[EmployeeCustomerMapping] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20180813-202321]
    ON [AVL].[EmployeeRoleMapping]([EmployeeCustomerMappingId] ASC, [RoleId] ASC);

