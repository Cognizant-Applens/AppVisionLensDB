CREATE TABLE [ESA].[BUParentAccounts] (
    [ParentCustomerMappingID] INT            IDENTITY (1, 1) NOT NULL,
    [ParentCustomerID]        INT            NULL,
    [ParentCustomerName]      VARCHAR (255)  NULL,
    [ESA_AccountID]           INT            NULL,
    [CustomerName]            VARCHAR (255)  NULL,
    [CustomerID]              INT            NULL,
    [IsActive]                BIT            NULL,
    [CreatedBy]               NVARCHAR (MAX) NULL,
    [CreatedDate]             DATETIME       NULL,
    [ModifiedBy]              NVARCHAR (MAX) NULL,
    [ModifiedDate]            DATETIME       NULL
);


GO
CREATE CLUSTERED INDEX [ClusteredIndex-20180917-124752]
    ON [ESA].[BUParentAccounts]([ParentCustomerMappingID] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_cid_isactive]
    ON [ESA].[BUParentAccounts]([IsActive] ASC)
    INCLUDE([ParentCustomerID], [ParentCustomerName], [CustomerID]);


GO
CREATE NONCLUSTERED INDEX [IDX_CusID_ParentCusID_ParentCusName]
    ON [ESA].[BUParentAccounts]([CustomerID] ASC)
    INCLUDE([ParentCustomerID], [ParentCustomerName]);


GO
CREATE NONCLUSTERED INDEX [IDX_ParentCusID_ParentCusName]
    ON [ESA].[BUParentAccounts]([ParentCustomerID] ASC)
    INCLUDE([ParentCustomerName]);

