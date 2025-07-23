CREATE TABLE [AVL].[MAS_MainspringAttributeStatusMaster] (
    [ID]                 INT            NOT NULL,
    [ServiceID]          INT            NULL,
    [ServiceName]        NVARCHAR (100) NULL,
    [AttributeID]        INT            NOT NULL,
    [AttributeName]      NVARCHAR (100) NOT NULL,
    [StatusID]           INT            NULL,
    [StatusName]         NVARCHAR (50)  NULL,
    [FieldType]          NVARCHAR (20)  NOT NULL,
    [CreatedDate]        DATETIME       NULL,
    [CreatedBy]          NVARCHAR (20)  NULL,
    [ModifiedDate]       DATETIME       NULL,
    [ModifiedBy]         NVARCHAR (20)  NULL,
    [IsDeleted]          BIT            NULL,
    [TicketDetailFields] NVARCHAR (500) NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_MAS_MainspringAttributeStatusMaster_ServiceID_StatusID_FieldType_IsDeleted]
    ON [AVL].[MAS_MainspringAttributeStatusMaster]([ServiceID] ASC, [StatusID] ASC, [FieldType] ASC, [IsDeleted] ASC)
    INCLUDE([AttributeID], [AttributeName]);

