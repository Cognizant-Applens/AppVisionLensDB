CREATE TABLE [SA].[MasterSelect] (
    [MasterId]        INT            IDENTITY (1, 1) NOT NULL,
    [TableName]       NVARCHAR (100) NULL,
    [ColumnId]        NVARCHAR (30)  NULL,
    [CreatedBy]       NVARCHAR (50)  NULL,
    [CreatedDateTime] DATETIME       NULL,
    [ErrorProcessing] BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([MasterId] ASC)
);

