CREATE TABLE [PP].[ProjectAttributeValues] (
    [ID]               BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]        BIGINT        NOT NULL,
    [AttributeValueID] INT           NOT NULL,
    [AttributeID]      SMALLINT      NOT NULL,
    [IsDeleted]        BIT           NOT NULL,
    [CreatedBy]        NVARCHAR (50) NOT NULL,
    [CreatedDate]      DATETIME      NOT NULL,
    [ModifiedBy]       NVARCHAR (50) NULL,
    [ModifiedDate]     DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    FOREIGN KEY ([AttributeID]) REFERENCES [MAS].[PPAttributes] ([AttributeID]),
    FOREIGN KEY ([AttributeValueID]) REFERENCES [MAS].[PPAttributeValues] ([AttributeValueID]),
    FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);


GO
CREATE NONCLUSTERED INDEX [NCI_ProjectAttributeValues_AttributeID_IsDeleted]
    ON [PP].[ProjectAttributeValues]([AttributeID] ASC, [IsDeleted] ASC)
    INCLUDE([ProjectID], [AttributeValueID]);


GO
CREATE NONCLUSTERED INDEX [NCI_ProjectAttributeValues_ProjectID_AttributeID_IsDeleted]
    ON [PP].[ProjectAttributeValues]([ProjectID] ASC, [AttributeID] ASC, [IsDeleted] ASC)
    INCLUDE([AttributeValueID]);


GO
CREATE NONCLUSTERED INDEX [NCI_ProjectAttributeValues_ProjectID_IsDeleted_AttributeValueID]
    ON [PP].[ProjectAttributeValues]([ProjectID] ASC, [IsDeleted] ASC, [AttributeValueID] ASC);

