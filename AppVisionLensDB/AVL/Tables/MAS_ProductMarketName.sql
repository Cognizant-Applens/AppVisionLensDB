CREATE TABLE [AVL].[MAS_ProductMarketName] (
    [ProductMarketID]   INT            IDENTITY (1, 1) NOT NULL,
    [ProductMarketName] NVARCHAR (200) NOT NULL,
    [IsDeleted]         BIT            NOT NULL,
    [CreatedBy]         NVARCHAR (50)  NOT NULL,
    [CreatedDate]       DATETIME       NOT NULL,
    PRIMARY KEY CLUSTERED ([ProductMarketID] ASC)
);

