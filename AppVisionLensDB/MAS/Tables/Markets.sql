CREATE TABLE [MAS].[Markets] (
    [MarketID]     INT            IDENTITY (1, 1) NOT NULL,
    [MarketName]   NVARCHAR (100) NOT NULL,
    [ESAMarketID]  NVARCHAR (50)  NOT NULL,
    [IsDeleted]    BIT            CONSTRAINT [DF_Markets_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    CONSTRAINT [PK_Markets] PRIMARY KEY CLUSTERED ([MarketID] ASC),
    CONSTRAINT [UK_Markets_ESAMarketID] UNIQUE NONCLUSTERED ([ESAMarketID] ASC),
    CONSTRAINT [UK_Markets_MarketName] UNIQUE NONCLUSTERED ([MarketName] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_Market]
    ON [MAS].[Markets]([IsDeleted] ASC)
    INCLUDE([MarketName]);

