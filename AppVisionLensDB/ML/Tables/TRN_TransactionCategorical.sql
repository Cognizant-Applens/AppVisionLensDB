CREATE TABLE [ML].[TRN_TransactionCategorical] (
    [CategoricalId]      BIGINT        IDENTITY (1, 1) NOT NULL,
    [MLTransactionId]    BIGINT        NOT NULL,
    [CategoricalFieldId] SMALLINT      NULL,
    [IsDeleted]          BIT           NOT NULL,
    [CreatedBy]          NVARCHAR (50) NOT NULL,
    [CreatedDate]        DATETIME      NOT NULL,
    [ModifiedBy]         NVARCHAR (50) NULL,
    [ModifiedDate]       DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([CategoricalId] ASC),
    FOREIGN KEY ([CategoricalFieldId]) REFERENCES [MAS].[ML_Prerequisite_FieldMapping] ([FieldMappingId]),
    FOREIGN KEY ([CategoricalFieldId]) REFERENCES [MAS].[ML_Prerequisite_FieldMapping] ([FieldMappingId]),
    FOREIGN KEY ([MLTransactionId]) REFERENCES [ML].[TRN_MLTransaction] ([TransactionId])
);

