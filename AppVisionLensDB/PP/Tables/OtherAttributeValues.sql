CREATE TABLE [PP].[OtherAttributeValues] (
    [ID]               BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]        BIGINT         NOT NULL,
    [AttributeValueID] INT            NOT NULL,
    [OtherFieldValue]  NVARCHAR (250) NOT NULL,
    [IsDeleted]        BIT            NOT NULL,
    [CreatedBY]        NVARCHAR (50)  NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [ModifiedBY]       NVARCHAR (50)  NULL,
    [ModifiedDate]     DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    FOREIGN KEY ([AttributeValueID]) REFERENCES [MAS].[PPAttributeValues] ([AttributeValueID])
);

