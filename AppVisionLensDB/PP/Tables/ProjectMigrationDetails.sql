CREATE TABLE [PP].[ProjectMigrationDetails] (
    [Id]                      INT           IDENTITY (1, 1) NOT NULL,
    [MigrationId]             NVARCHAR (20) NOT NULL,
    [MigrationStartDateTime]  DATETIME      NULL,
    [MigrationEndDateTime]    DATETIME      NULL,
    [SourceESAProjectId]      NVARCHAR (50) NOT NULL,
    [DestinationESAProjectId] NVARCHAR (50) NOT NULL,
    [MigrationStatusId]       INT           NOT NULL,
    [IsDeleted]               BIT           NOT NULL,
    [Createdby]               NVARCHAR (50) NOT NULL,
    [CreatedDate]             DATETIME      NOT NULL,
    [ModifiedBy]              NVARCHAR (50) NULL,
    [ModifiedDate]            DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    FOREIGN KEY ([MigrationId]) REFERENCES [PP].[ProjectMigrationRequest] ([MigrationId]),
    FOREIGN KEY ([MigrationStatusId]) REFERENCES [MAS].[PPAttributeValues] ([AttributeValueID])
);

