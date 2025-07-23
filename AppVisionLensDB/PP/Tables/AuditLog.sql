CREATE TABLE [PP].[AuditLog] (
    [AuditID]      BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]    BIGINT         NOT NULL,
    [AttributeID]  SMALLINT       NOT NULL,
    [FromValue]    NVARCHAR (250) NULL,
    [ToValue]      NVARCHAR (250) NULL,
    [IsDeleted]    BIT            NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    FOREIGN KEY ([AttributeID]) REFERENCES [MAS].[PPAttributes] ([AttributeID]),
    FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

