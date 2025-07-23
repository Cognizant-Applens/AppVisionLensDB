CREATE TABLE [MS].[MAS_NumeratorandDenomonatorPosition_Master] (
    [PositionID]   INT           IDENTITY (1, 1) NOT NULL,
    [PositionName] NVARCHAR (50) NULL,
    CONSTRAINT [PK_NumeratorandDenomonatorPosition_Master] PRIMARY KEY CLUSTERED ([PositionID] ASC) WITH (FILLFACTOR = 70)
);

