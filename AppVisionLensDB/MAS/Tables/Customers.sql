CREATE TABLE [MAS].[Customers] (
    [CustomerID]       INT            IDENTITY (1, 1) NOT NULL,
    [CustomerName]     NVARCHAR (160) NOT NULL,
    [ESACustomerID]    NVARCHAR (50)  NOT NULL,
    [ParentCustomerID] INT            NULL,
    [SBU1ID]           INT            NOT NULL,
    [SBU2ID]           INT            NULL,
    [VerticalID]       INT            NOT NULL,
    [SubVerticalID]    INT            NULL,
    [IsDeleted]        BIT            CONSTRAINT [DF_Customers_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]        NVARCHAR (50)  NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [ModifiedBy]       NVARCHAR (50)  NULL,
    [ModifiedDate]     DATETIME       NULL,
    CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ([CustomerID] ASC),
    CONSTRAINT [FK_Customers_ParentCustomers] FOREIGN KEY ([ParentCustomerID]) REFERENCES [MAS].[ParentCustomers] ([ParentCustomerID]),
    CONSTRAINT [FK_Customers_SubBusinessUnits1] FOREIGN KEY ([SBU1ID]) REFERENCES [MAS].[SubBusinessUnits1] ([SBU1ID]),
    CONSTRAINT [FK_Customers_SubBusinessUnits2] FOREIGN KEY ([SBU2ID]) REFERENCES [MAS].[SubBusinessUnits2] ([SBU2ID]),
    CONSTRAINT [FK_Customers_SubVerticals] FOREIGN KEY ([SubVerticalID]) REFERENCES [MAS].[SubVerticals] ([SubVerticalID]),
    CONSTRAINT [FK_Customers_Verticals] FOREIGN KEY ([VerticalID]) REFERENCES [MAS].[Verticals] ([VerticalID]),
    CONSTRAINT [UK_Customers_ESACustomerID] UNIQUE NONCLUSTERED ([ESACustomerID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_Customers]
    ON [MAS].[Customers]([IsDeleted] ASC)
    INCLUDE([CustomerName], [ESACustomerID], [ParentCustomerID], [SBU1ID], [SBU2ID], [VerticalID], [SubVerticalID]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'', @level0type = N'SCHEMA', @level0name = N'MAS', @level1type = N'TABLE', @level1name = N'Customers';

