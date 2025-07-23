CREATE TABLE [ESA].[ESABusinessUnit] (
    [BusinessUnitID]    INT            IDENTITY (1, 1) NOT NULL,
    [MarketUnitID]      INT            NOT NULL,
    [ESABusinessUnitID] VARCHAR (255)  NULL,
    [BusinessUnitName]  NVARCHAR (100) NOT NULL,
    [IsDeleted]         BIT            NOT NULL,
    [CreatedBy]         NVARCHAR (50)  NOT NULL,
    [CreatedDateTime]   DATETIME       NOT NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL,
    [ModifiedDateTime]  DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([BusinessUnitID] ASC),
    CONSTRAINT [FK_BusinessUnit_MarketUnit] FOREIGN KEY ([MarketUnitID]) REFERENCES [ESA].[MarketUnit] ([MarketUnitID])
);

