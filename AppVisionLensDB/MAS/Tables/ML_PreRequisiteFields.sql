CREATE TABLE [MAS].[ML_PreRequisiteFields] (
    [FieldId]      SMALLINT      IDENTITY (1, 1) NOT NULL,
    [FieldName]    NVARCHAR (50) NOT NULL,
    [FieldKey]     NVARCHAR (6)  NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([FieldId] ASC)
);

