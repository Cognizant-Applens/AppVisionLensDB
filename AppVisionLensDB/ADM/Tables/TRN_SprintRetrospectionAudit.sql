CREATE TABLE [ADM].[TRN_SprintRetrospectionAudit] (
    [SprintRetrospectionAuditId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [SprintId]                   BIGINT        NOT NULL,
    [StageId]                    BIGINT        NOT NULL,
    [CompletedBy]                NVARCHAR (50) NOT NULL,
    [Isdeleted]                  BIT           NOT NULL,
    [CreatedBy]                  NVARCHAR (50) NOT NULL,
    [CreatedOn]                  DATETIME      NOT NULL,
    [ModifiedBy]                 NVARCHAR (50) NULL,
    [ModifiedOn]                 DATETIME      NULL,
    CONSTRAINT [PK_TRN_SprintRetrospectionAudit] PRIMARY KEY CLUSTERED ([SprintRetrospectionAuditId] ASC),
    FOREIGN KEY ([SprintId]) REFERENCES [ADM].[ALM_TRN_Sprint_Details] ([SprintDetailsId]),
    FOREIGN KEY ([StageId]) REFERENCES [ADM].[MAS_Source] ([SourceId])
);

