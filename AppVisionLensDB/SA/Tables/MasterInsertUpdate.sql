CREATE TABLE [SA].[MasterInsertUpdate] (
    [MasterId]        INT            IDENTITY (1, 1) NOT NULL,
    [TableName]       NVARCHAR (100) NULL,
    [ColumnId]        NVARCHAR (30)  NULL,
    [ColumnName]      NVARCHAR (50)  NULL,
    [ColumnValue]     NVARCHAR (255) NULL,
    [ProcessType]     BIT            NOT NULL,
    [CreatedBy]       NVARCHAR (50)  NULL,
    [CreatedDateTime] DATETIME       NULL,
    [ErrorProcessing] BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([MasterId] ASC)
);

