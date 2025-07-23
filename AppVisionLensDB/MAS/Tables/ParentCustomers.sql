CREATE TABLE [MAS].[ParentCustomers] (
    [ParentCustomerID]    INT            IDENTITY (1, 1) NOT NULL,
    [ParentCustomerName]  NVARCHAR (160) NOT NULL,
    [ESAParentCustomerID] NVARCHAR (50)  NOT NULL,
    [IsDeleted]           BIT            CONSTRAINT [DF_ParentCustomers_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]           NVARCHAR (50)  NOT NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [ModifiedBy]          NVARCHAR (50)  NULL,
    [ModifiedDate]        DATETIME       NULL,
    CONSTRAINT [PK_ParentCustomers] PRIMARY KEY CLUSTERED ([ParentCustomerID] ASC),
    CONSTRAINT [UK_ParentCustomers_ESAParentCustomerID] UNIQUE NONCLUSTERED ([ESAParentCustomerID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_ParentCustomers]
    ON [MAS].[ParentCustomers]([IsDeleted] ASC)
    INCLUDE([ParentCustomerName]);

