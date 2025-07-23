CREATE TABLE [AVL].[PRJ_MainspringAttributeProjectStatusMaster] (
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
    [IsDeleted]          BIT           NULL,
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [Projectid]          INT           NULL,
    [TicketMasterFields] VARCHAR (MAX) NULL
);


GO
CREATE NONCLUSTERED INDEX [CTSDBAIndex7]
    ON [AVL].[PRJ_MainspringAttributeProjectStatusMaster]([ServiceID] ASC, [StatusID] ASC, [FieldType] ASC, [IsDeleted] ASC, [Projectid] ASC)
    INCLUDE([AttributeID], [AttributeName]);


GO
CREATE NONCLUSTERED INDEX [IX_NC_PRJ_MainspringAttributeProjectStatusMaster_Isdeleted_projectID]
    ON [AVL].[PRJ_MainspringAttributeProjectStatusMaster]([IsDeleted] ASC, [Projectid] ASC);


GO
CREATE NONCLUSTERED INDEX [PK_PRJ_MainspringAttributeProjectStatusMaster_Projectid_AttributeID]
    ON [AVL].[PRJ_MainspringAttributeProjectStatusMaster]([Projectid] ASC, [AttributeID] ASC);

