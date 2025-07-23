CREATE TABLE [MAS].[BusinessUnits] (
    [BusinessUnitID]    INT            IDENTITY (1, 1) NOT NULL,
    [BusinessUnitName]  NVARCHAR (100) NOT NULL,
    [ESABusinessUnitID] NVARCHAR (50)  NOT NULL,
    [MarketUnitID]      INT            NOT NULL,
    [IsDeleted]         BIT            CONSTRAINT [DF_BusinessUnits_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]         NVARCHAR (50)  NOT NULL,
    [CreatedDate]       DATETIME       NOT NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL,
    [ModifiedDate]      DATETIME       NULL,
    CONSTRAINT [PK_BusinessUnits] PRIMARY KEY CLUSTERED ([BusinessUnitID] ASC),
    CONSTRAINT [FK_BusinessUnits_MarketUnits] FOREIGN KEY ([MarketUnitID]) REFERENCES [MAS].[MarketUnits] ([MarketUnitID]),
    CONSTRAINT [UK_BusinessUnits_ESABusinessUnitID] UNIQUE NONCLUSTERED ([ESABusinessUnitID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_BusinessUnits]
    ON [MAS].[BusinessUnits]([IsDeleted] ASC)
    INCLUDE([BusinessUnitName], [MarketUnitID]);

