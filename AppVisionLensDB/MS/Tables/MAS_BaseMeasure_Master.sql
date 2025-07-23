CREATE TABLE [MS].[MAS_BaseMeasure_Master] (
    [BaseMeasureID]     INT            IDENTITY (1, 1) NOT NULL,
    [BaseMeasureName]   NVARCHAR (200) NULL,
    [BaseMeasureTypeID] INT            NULL,
    [UOMID]             INT            NULL,
    [IsDeleted]         BIT            NULL,
    CONSTRAINT [PK_BaseMeasure_Master] PRIMARY KEY CLUSTERED ([BaseMeasureID] ASC) WITH (FILLFACTOR = 70)
);

