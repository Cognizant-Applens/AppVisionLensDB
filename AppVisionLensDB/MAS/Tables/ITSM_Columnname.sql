CREATE TABLE [MAS].[ITSM_Columnname] (
    [ColumnID]      INT           IDENTITY (1, 1) NOT NULL,
    [ColumnName]    NVARCHAR (50) NOT NULL,
    [SupportTypeID] INT           NOT NULL,
    [IsMandatory]   BIT           NOT NULL,
    [IsDeleted]     BIT           NOT NULL,
    [CreatedBy]     NVARCHAR (50) NOT NULL,
    [CreatedDate]   DATETIME      NOT NULL,
    [ModifiedBy]    NVARCHAR (50) NULL,
    [ModifiedDate]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ColumnID] ASC),
    FOREIGN KEY ([SupportTypeID]) REFERENCES [AVL].[SupportTypeMaster] ([SupportTypeId])
);

