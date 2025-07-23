CREATE TABLE [PP].[ProjectMigrationRequest] (
    [MigrationId]       NVARCHAR (20) NOT NULL,
    [RequestedBy]       NVARCHAR (50) NOT NULL,
    [RequestedDate]     DATETIME      NOT NULL,
    [MigrationTypeId]   INT           NOT NULL,
    [MigrationStatusId] INT           NOT NULL,
    [IsDeleted]         BIT           NOT NULL,
    [CreatedBy]         NVARCHAR (50) NOT NULL,
    [CreatedDate]       DATETIME      NOT NULL,
    [ModifiedBy]        NVARCHAR (50) NULL,
    [ModifiedDate]      DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([MigrationId] ASC),
    FOREIGN KEY ([MigrationStatusId]) REFERENCES [MAS].[PPAttributeValues] ([AttributeValueID]),
    FOREIGN KEY ([MigrationTypeId]) REFERENCES [MAS].[PPAttributeValues] ([AttributeValueID])
);

