CREATE TABLE [AVL].[MAS_StandardAttributeStatusMaster] (
    [ServiceID]          INT           NULL,
    [ServiceName]        VARCHAR (100) NULL,
    [AttributeID]        INT           NOT NULL,
    [AttributeName]      VARCHAR (100) NOT NULL,
    [StatusID]           INT           NOT NULL,
    [StatusName]         VARCHAR (100) NOT NULL,
    [FieldType]          VARCHAR (20)  NOT NULL,
    [CreatedDateTime]    DATETIME      NULL,
    [CreatedBy]          VARCHAR (10)  NULL,
    [ModifiedDateTime]   DATETIME      NULL,
    [ModifiedBy]         VARCHAR (10)  NULL,
    [IsDeleted]          CHAR (1)      NOT NULL,
    [ID]                 INT           NOT NULL,
    [TicketMasterFields] VARCHAR (MAX) NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_MAS_StandardAttributeStatusMaster_ServiceID_StatusID_FieldType]
    ON [AVL].[MAS_StandardAttributeStatusMaster]([ServiceID] ASC, [StatusID] ASC, [FieldType] ASC)
    INCLUDE([AttributeID], [AttributeName], [IsDeleted]);

