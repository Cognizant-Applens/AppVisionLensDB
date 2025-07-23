CREATE TABLE [PP].[ALM_SourceColumn] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]    BIGINT         NOT NULL,
    [ColumnName]   NVARCHAR (200) NOT NULL,
    [IsDeleted]    BIT            NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

