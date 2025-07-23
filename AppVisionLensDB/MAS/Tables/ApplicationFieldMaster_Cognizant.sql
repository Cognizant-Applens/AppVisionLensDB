CREATE TABLE [MAS].[ApplicationFieldMaster_Cognizant] (
    [ID]                        INT           IDENTITY (1, 1) NOT NULL,
    [ColumnID]                  INT           NOT NULL,
    [ColumnName]                VARCHAR (200) NOT NULL,
    [DataType]                  VARCHAR (50)  NOT NULL,
    [MandatoryID]               INT           NULL,
    [ParentColumnIDConditional] INT           NULL,
    [PositionInExcel]           VARCHAR (10)  NULL,
    [MaxLength]                 INT           NULL,
    [WaterMarkText]             VARCHAR (MAX) NULL,
    [IsDeleted]                 VARCHAR (10)  NULL,
    [IsParent]                  INT           NULL,
    [DataTypeLength]            VARCHAR (100) NULL,
    [ExcelTemplateColumnName]   VARCHAR (MAX) NULL,
    [OrderPositionInExcel]      INT           NULL,
    [TVPColumnName]             VARCHAR (100) NULL,
    [isCognizant]               INT           NULL,
    [ColumnShown]               INT           NULL,
    [CreatedBy]                 VARCHAR (25)  NULL,
    [CreatedDate]               DATETIME      NULL,
    [ModifiedBy]                VARCHAR (25)  NULL,
    [ModifiedOn]                DATETIME      NULL
);

