CREATE TABLE [AVL].[PRJ_StandardAttributeProjectStatusMaster] (
    [ServiceID]          INT            NULL,
    [ServiceName]        NVARCHAR (100) NULL,
    [AttributeID]        INT            NOT NULL,
    [AttributeName]      NVARCHAR (100) NOT NULL,
    [StatusID]           INT            NOT NULL,
    [StatusName]         NVARCHAR (100) NOT NULL,
    [FieldType]          NVARCHAR (20)  NOT NULL,
    [CreatedDate]        DATETIME       NULL,
    [CreatedBy]          NVARCHAR (10)  NULL,
    [ModifiedDate]       DATETIME       NULL,
    [ModifiedBy]         NVARCHAR (10)  NULL,
    [IsDeleted]          BIT            NULL,
    [ID]                 INT            IDENTITY (1, 1) NOT NULL,
    [Projectid]          INT            NULL,
    [TicketMasterFields] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_PRJ_StandardAttributeProjectStatusMaster] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [CTSDBAIndex10]
    ON [AVL].[PRJ_StandardAttributeProjectStatusMaster]([ServiceID] ASC, [StatusID] ASC, [FieldType] ASC, [IsDeleted] ASC, [Projectid] ASC)
    INCLUDE([AttributeID], [AttributeName]);


GO
CREATE NONCLUSTERED INDEX [PK_PRJ_StandardAttributeProjectStatusMaster_Projectid_AttributeID]
    ON [AVL].[PRJ_StandardAttributeProjectStatusMaster]([Projectid] ASC, [AttributeID] ASC);

