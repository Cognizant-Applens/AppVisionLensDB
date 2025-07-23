CREATE TABLE [ADM].[WorkItemMandateAttributeMapping] (
    [MandateAttributeId] INT           IDENTITY (1, 1) NOT NULL,
    [AttributeId]        SMALLINT      NOT NULL,
    [ExecutionMethodId]  BIGINT        NOT NULL,
    [MandateId]          SMALLINT      NOT NULL,
    [IsDeleted]          BIT           NOT NULL,
    [CreatedBy]          NVARCHAR (50) NOT NULL,
    [CreatedDate]        DATETIME      NOT NULL,
    [ModifiedBy]         NVARCHAR (50) NULL,
    [ModifiedDate]       DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([MandateAttributeId] ASC),
    FOREIGN KEY ([AttributeId]) REFERENCES [ADM].[MAS_WorkItemAttributes] ([AttributeId]),
    FOREIGN KEY ([ExecutionMethodId]) REFERENCES [ADM].[ExecutionMethod] ([ID]),
    CONSTRAINT [FK__WorkItemM__Manda__28B11462] FOREIGN KEY ([MandateId]) REFERENCES [ADM].[MAS_MandateApplicability] ([MandateId])
);

