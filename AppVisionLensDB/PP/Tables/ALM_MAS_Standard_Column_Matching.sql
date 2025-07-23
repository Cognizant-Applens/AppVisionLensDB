CREATE TABLE [PP].[ALM_MAS_Standard_Column_Matching] (
    [ColumnMatchingId]  INT            IDENTITY (1, 1) NOT NULL,
    [ColumnMappingId]   BIGINT         NOT NULL,
    [PriorityMappingId] INT            NOT NULL,
    [MatchingKeyword]   NVARCHAR (200) NOT NULL,
    [IsDeleted]         BIT            NOT NULL,
    [CreatedBy]         NVARCHAR (50)  NOT NULL,
    [CreatedDate]       DATETIME       NOT NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL,
    [ModifiedDate]      DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ColumnMatchingId] ASC),
    FOREIGN KEY ([ColumnMappingId]) REFERENCES [PP].[ALM_MAS_ColumnName] ([ALMColID]),
    FOREIGN KEY ([PriorityMappingId]) REFERENCES [PP].[ALM_MAS_Priority_ColumnMapping] ([PriorityMappingId])
);

