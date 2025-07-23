CREATE TABLE [AVL].[MAS_TicketTypeStatusAttributeMaster] (
    [ID]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [TicketTypeID]       INT            NULL,
    [AttributeID]        INT            NOT NULL,
    [StatusID]           INT            NULL,
    [FieldType]          NVARCHAR (20)  NOT NULL,
    [CreatedDate]        DATETIME       NULL,
    [CreatedBy]          NVARCHAR (20)  NULL,
    [ModifiedDate]       DATETIME       NULL,
    [ModifiedBy]         NVARCHAR (20)  NULL,
    [IsDeleted]          BIT            NULL,
    [TicketDetailFields] NVARCHAR (500) NULL
);

