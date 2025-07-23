CREATE TABLE [ESA].[Market] (
    [MarketID]         INT            IDENTITY (1, 1) NOT NULL,
    [ESAMarketID]      VARCHAR (255)  NULL,
    [MarketName]       NVARCHAR (255) NOT NULL,
    [IsDeleted]        BIT            NOT NULL,
    [CreatedBy]        NVARCHAR (50)  NOT NULL,
    [CreatedDateTime]  DATETIME       NOT NULL,
    [ModifiedBy]       NVARCHAR (50)  NULL,
    [ModifiedDateTime] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([MarketID] ASC)
);

