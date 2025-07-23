CREATE TABLE [MAS].[MarketUnits] (
    [MarketUnitID]    INT            IDENTITY (1, 1) NOT NULL,
    [MarketUnitName]  NVARCHAR (100) NOT NULL,
    [MarketID]        INT            NOT NULL,
    [ESAMarketUnitID] NVARCHAR (50)  NOT NULL,
    [IsDeleted]       BIT            CONSTRAINT [DF_MarketUnits_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]       NVARCHAR (50)  NOT NULL,
    [CreatedDate]     DATETIME       NOT NULL,
    [ModifiedBy]      NVARCHAR (50)  NULL,
    [ModifiedDate]    DATETIME       NULL,
    CONSTRAINT [PK_MarketUnits] PRIMARY KEY CLUSTERED ([MarketUnitID] ASC),
    CONSTRAINT [FK_MarketUnits_Markets] FOREIGN KEY ([MarketID]) REFERENCES [MAS].[Markets] ([MarketID]),
    CONSTRAINT [UK_MarketUnits_ESAMarketUnitID] UNIQUE NONCLUSTERED ([ESAMarketUnitID] ASC),
    CONSTRAINT [UK_MarketUnits_MarketUnitName] UNIQUE NONCLUSTERED ([MarketUnitName] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_MarketUnits]
    ON [MAS].[MarketUnits]([IsDeleted] ASC)
    INCLUDE([MarketUnitName], [MarketID]);

