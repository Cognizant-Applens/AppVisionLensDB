CREATE TABLE [MS].[MAS_UOM_Master] (
    [UOMID]        INT           IDENTITY (1, 1) NOT NULL,
    [UOM_DESC]     NVARCHAR (50) NULL,
    [UOM_DataType] NVARCHAR (50) NULL,
    [IsDeleted]    BIT           NULL,
    CONSTRAINT [PK_UOM_Master] PRIMARY KEY CLUSTERED ([UOMID] ASC) WITH (FILLFACTOR = 70)
);

