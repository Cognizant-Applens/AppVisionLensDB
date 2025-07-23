CREATE TABLE [ESA].[MarketUnit] (
    [MarketUnitID]     INT            IDENTITY (1, 1) NOT NULL,
    [ESAMarketUnitID]  NVARCHAR (255) NULL,
    [MarketUnitName]   NVARCHAR (255) NOT NULL,
    [MarketID]         INT            NOT NULL,
    [IsDeleted]        BIT            NOT NULL,
    [CreatedBy]        NVARCHAR (50)  NOT NULL,
    [CreatedDateTime]  DATETIME       NOT NULL,
    [ModifiedBy]       NVARCHAR (50)  NULL,
    [ModifiedDateTime] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([MarketUnitID] ASC),
    CONSTRAINT [FK_MarketUnit_Market] FOREIGN KEY ([MarketID]) REFERENCES [ESA].[Market] ([MarketID])
);

