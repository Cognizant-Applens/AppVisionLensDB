CREATE TABLE [MAS].[PPAttributeValues] (
    [AttributeValueID]    INT            IDENTITY (1, 1) NOT NULL,
    [AttributeValueName]  NVARCHAR (200) NOT NULL,
    [AttributeID]         SMALLINT       NOT NULL,
    [IsDeleted]           BIT            NOT NULL,
    [CreatedBy]           NVARCHAR (50)  NOT NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [ParentID]            INT            NULL,
    [AttributeValueOrder] SMALLINT       NULL,
    PRIMARY KEY CLUSTERED ([AttributeValueID] ASC),
    FOREIGN KEY ([AttributeID]) REFERENCES [MAS].[PPAttributes] ([AttributeID])
);

