CREATE TABLE [PP].[MLMultiAlgoConfiguration] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [ProjectID]    BIGINT        NOT NULL,
    [AlgorithmId]  INT           NOT NULL,
    [Preference]   SMALLINT      NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    FOREIGN KEY ([AlgorithmId]) REFERENCES [MAS].[PPAttributeValues] ([AttributeValueID]),
    FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

