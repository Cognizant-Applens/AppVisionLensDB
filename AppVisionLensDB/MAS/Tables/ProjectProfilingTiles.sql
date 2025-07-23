CREATE TABLE [MAS].[ProjectProfilingTiles] (
    [TileID]           SMALLINT       IDENTITY (1, 1) NOT NULL,
    [TileName]         NVARCHAR (50)  NOT NULL,
    [TileDescription]  NVARCHAR (250) NOT NULL,
    [IsDeleted]        BIT            NOT NULL,
    [CreatedBy]        NVARCHAR (50)  NOT NULL,
    [CreatedDateTime]  DATETIME       NOT NULL,
    [ModifiedBy]       NVARCHAR (50)  NULL,
    [ModifiedDateTime] DATETIME       NULL,
    [ParentID]         SMALLINT       NULL,
    PRIMARY KEY CLUSTERED ([TileID] ASC)
);

