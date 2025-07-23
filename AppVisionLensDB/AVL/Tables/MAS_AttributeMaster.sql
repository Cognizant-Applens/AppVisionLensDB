CREATE TABLE [AVL].[MAS_AttributeMaster] (
    [AttributeID]        INT             NOT NULL,
    [AttributeName]      VARCHAR (50)    NULL,
    [IsDefaultAttribute] NVARCHAR (1)    NULL,
    [IsMandatory]        NVARCHAR (1)    NULL,
    [IsDeleted]          BIT             NULL,
    [CreatedDate]        DATETIME        NULL,
    [ModifiedDate]       DATETIME        NULL,
    [CreatedBy]          NUMERIC (18, 2) NULL,
    [ModifiedBy]         NUMERIC (18, 2) NULL,
    [AttributeType]      NVARCHAR (10)   NULL,
    [TicketDetailFields] NVARCHAR (1000) NULL,
    CONSTRAINT [PK__Attribut__C189298A22D7A5EE] PRIMARY KEY CLUSTERED ([AttributeID] ASC) WITH (FILLFACTOR = 70)
);

