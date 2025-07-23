CREATE TABLE [AVL].[MAS_InfraAttributeStatusMaster] (
    [ID]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [AttributeID]        INT            NOT NULL,
    [AttributeName]      NVARCHAR (100) NOT NULL,
    [StatusID]           INT            NULL,
    [StatusName]         NVARCHAR (50)  NULL,
    [StandardFieldType]  CHAR (1)       NOT NULL,
    [DebtFieldType]      CHAR (1)       NOT NULL,
    [TicketDetailFields] NVARCHAR (500) NULL,
    [AttributeType]      NVARCHAR (50)  NULL,
    [IsDeleted]          BIT            NULL,
    [CreatedDate]        DATETIME       NULL,
    [CreatedBy]          NVARCHAR (20)  NULL,
    [ModifiedDate]       DATETIME       NULL,
    [ModifiedBy]         NVARCHAR (20)  NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

