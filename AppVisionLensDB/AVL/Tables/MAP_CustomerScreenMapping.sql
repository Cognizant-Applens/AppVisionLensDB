CREATE TABLE [AVL].[MAP_CustomerScreenMapping] (
    [CustomerScreenMapID] BIGINT       IDENTITY (1, 1) NOT NULL,
    [CustomerID]          BIGINT       NOT NULL,
    [ScreenID]            INT          NOT NULL,
    [IsEnabled]           BIT          NULL,
    [IsActive]            BIT          NULL,
    [CreatedDate]         DATETIME     NULL,
    [CreatedBy]           VARCHAR (50) NULL,
    [ModifiedDate]        DATETIME     NULL,
    [ModifiedBy]          VARCHAR (50) NULL
);

