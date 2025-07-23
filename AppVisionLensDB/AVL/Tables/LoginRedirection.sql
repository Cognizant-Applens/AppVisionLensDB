CREATE TABLE [AVL].[LoginRedirection] (
    [ID]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [CustomerID]   BIGINT        NOT NULL,
    [CustomerName] NVARCHAR (50) NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([CustomerID] ASC),
    FOREIGN KEY ([CustomerID]) REFERENCES [AVL].[Customer] ([CustomerID])
);

