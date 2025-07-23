CREATE TABLE [PP].[ProjectProfilingTileProgress] (
    [TileProgressID]         BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]              BIGINT        NOT NULL,
    [TileID]                 SMALLINT      NOT NULL,
    [TileProgressPercentage] INT           NOT NULL,
    [IsDeleted]              BIT           NOT NULL,
    [CreatedBy]              NVARCHAR (50) NOT NULL,
    [CreatedDateTime]        DATETIME      NOT NULL,
    [ModifiedBy]             NVARCHAR (50) NULL,
    [ModifiedDateTime]       DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([TileProgressID] ASC),
    FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    FOREIGN KEY ([TileID]) REFERENCES [MAS].[ProjectProfilingTiles] ([TileID])
);


GO
CREATE NONCLUSTERED INDEX [NCI_ProjectProfilingTileProgress_ProjectID]
    ON [PP].[ProjectProfilingTileProgress]([ProjectID] ASC)
    INCLUDE([TileID], [TileProgressPercentage]);


GO
CREATE NONCLUSTERED INDEX [NCI_ProjectProfilingTileProgress_ProjectID_IsDeleted_TileID_TileProgressPercentage]
    ON [PP].[ProjectProfilingTileProgress]([ProjectID] ASC, [IsDeleted] ASC, [TileID] ASC, [TileProgressPercentage] ASC);

