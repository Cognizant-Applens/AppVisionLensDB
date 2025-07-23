CREATE TABLE [AVL].[DEBT_MAS_HealColumnMaster] (
    [ID]                            INT           IDENTITY (1, 1) NOT NULL,
    [ColumnID]                      INT           NULL,
    [ColumnName]                    VARCHAR (100) NULL,
    [ColumnType]                    VARCHAR (50)  NULL,
    [IsMandatory]                   VARCHAR (10)  NULL,
    [IsProjectDefined]              VARCHAR (10)  NULL,
    [IsActive]                      BIT           NULL,
    [CreatedBy]                     VARCHAR (10)  NULL,
    [CreatedDate]                   DATETIME      NULL,
    [ModifiedBy]                    VARCHAR (10)  NULL,
    [ModifiedDate]                  DATETIME      NULL,
    [TicketMasterColumnName]        VARCHAR (500) NULL,
    [OfflineTicketMasterColumnName] VARCHAR (500) NULL
);

