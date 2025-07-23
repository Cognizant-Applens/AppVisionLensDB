CREATE TABLE [MS].[MAS_serviceOffering2_Master] (
    [ServiceOffering2ID]  INT            IDENTITY (1, 1) NOT NULL,
    [ServiceOfferingDESC] NVARCHAR (200) NULL,
    [IsDeleted]           BIT            NULL,
    CONSTRAINT [PK_serviceOffering2_Master] PRIMARY KEY CLUSTERED ([ServiceOffering2ID] ASC) WITH (FILLFACTOR = 70)
);

