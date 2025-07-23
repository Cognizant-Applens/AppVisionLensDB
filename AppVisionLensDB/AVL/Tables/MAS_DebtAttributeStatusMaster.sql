CREATE TABLE [AVL].[MAS_DebtAttributeStatusMaster] (
    [ID]                 INT            NOT NULL,
    [TicketMasterFields] NVARCHAR (MAX) NULL,
    [ServiceID]          INT            NULL,
    [ServiceName]        NVARCHAR (100) NULL,
    [AttributeID]        INT            NOT NULL,
    [AttributeName]      NVARCHAR (100) NOT NULL,
    [StatusID]           INT            NOT NULL,
    [StatusName]         NVARCHAR (100) NOT NULL,
    [FieldType]          NVARCHAR (20)  NOT NULL,
    [IsDeleted]          BIT            NOT NULL,
    [CreatedDateTime]    DATETIME       NULL,
    [CreatedBy]          NVARCHAR (10)  NULL,
    [ModifiedDateTime]   DATETIME       NULL,
    [ModifiedBy]         NVARCHAR (10)  NULL
);

