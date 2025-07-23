CREATE TABLE [dbo].[LogViewerConfig] (
    [ID]                    INT            IDENTITY (1, 1) NOT NULL,
    [ApplicationID]         BIGINT         NULL,
    [DatabaseName]          NVARCHAR (128) NOT NULL,
    [FeatureName]           NVARCHAR (128) NOT NULL,
    [TableName]             NVARCHAR (128) NOT NULL,
    [DateFilterColumnName]  NVARCHAR (128) NOT NULL,
    [DescriptionColumnName] NVARCHAR (128) NOT NULL,
    [IsDeleted]             BIT            DEFAULT ((0)) NOT NULL,
    [CreatedBy]             NVARCHAR (50)  NULL,
    [CreatedDate]           DATETIME       NULL,
    [ModifiedBy]            NVARCHAR (50)  NULL,
    [ModifiedDate]          DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

