CREATE TABLE [MS].[MAP_ServiceBaseMeasure_Mapping] (
    [ServiceBaseMeasureMapID] INT IDENTITY (1, 1) NOT NULL,
    [ServiceID]               INT NULL,
    [BaseMeasureID]           INT NULL,
    [IsDeleted]               BIT NULL,
    CONSTRAINT [PK_ServiceBaseMeasure_Mapping] PRIMARY KEY CLUSTERED ([ServiceBaseMeasureMapID] ASC) WITH (FILLFACTOR = 70)
);

