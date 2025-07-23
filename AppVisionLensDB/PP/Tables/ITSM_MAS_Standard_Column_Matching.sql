CREATE TABLE [PP].[ITSM_MAS_Standard_Column_Matching] (
    [ColumnMatchingId]  INT            IDENTITY (1, 1) NOT NULL,
    [ColumnMappingId]   INT            NOT NULL,
    [PriorityMappingId] INT            NOT NULL,
    [MatchingKeyword]   NVARCHAR (100) NOT NULL,
    [IsDeleted]         BIT            NOT NULL,
    [CreatedBy]         NVARCHAR (50)  NOT NULL,
    [CreatedDate]       DATETIME       NOT NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL,
    [ModifiedDate]      DATETIME       NULL,
    FOREIGN KEY ([ColumnMappingId]) REFERENCES [MAS].[ITSM_Columnname] ([ColumnID]),
    FOREIGN KEY ([PriorityMappingId]) REFERENCES [PP].[ALM_MAS_Priority_ColumnMapping] ([PriorityMappingId])
);

