CREATE TABLE [AVL].[KEDB_TRN_KATicketDetails] (
    [KAId]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [ProjectId]            BIGINT          NULL,
    [KATicketID]           NVARCHAR (50)   NULL,
    [KATitle]              NVARCHAR (1000) NULL,
    [Status]               NVARCHAR (20)   NULL,
    [AuthorName]           NVARCHAR (100)  NULL,
    [ApplicationId]        BIGINT          NULL,
    [CauseCodeId]          BIGINT          NULL,
    [ResolutionId]         BIGINT          NULL,
    [Description]          NVARCHAR (4000) NULL,
    [KeyWords]             NVARCHAR (300)  NULL,
    [Effort]               DECIMAL (25, 2) NULL,
    [AutomationScope]      NVARCHAR (20)   NULL,
    [ApprovedOrRejectedBy] NVARCHAR (50)   NULL,
    [ReviewComments]       NVARCHAR (250)  NULL,
    [CreatedBy]            NVARCHAR (50)   NULL,
    [CreatedOn]            DATETIME        DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]           NVARCHAR (50)   NULL,
    [ModifiedOn]           DATETIME        NULL,
    [IsDeleted]            BIT             NULL,
    [Remarks]              NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_KEDB_TRN_KATicketDetails] PRIMARY KEY CLUSTERED ([KAId] ASC),
    CONSTRAINT [FK_KEDB_KAID_Application] FOREIGN KEY ([ApplicationId]) REFERENCES [AVL].[APP_MAS_ApplicationDetails] ([ApplicationID])
);


GO
CREATE NONCLUSTERED INDEX [NC_Index_KEDB_KAProject_active,>]
    ON [AVL].[KEDB_TRN_KATicketDetails]([ProjectId] ASC, [IsDeleted] ASC)
    INCLUDE([KATicketID], [KATitle], [Status], [AuthorName], [ApplicationId], [CauseCodeId], [ResolutionId], [Effort], [CreatedBy]);


GO
CREATE NONCLUSTERED INDEX [NC_KATicket_Pro_Tick_Isdeleted]
    ON [AVL].[KEDB_TRN_KATicketDetails]([ProjectId] ASC, [KATicketID] ASC, [IsDeleted] ASC, [Status] ASC)
    INCLUDE([KAId], [KATitle], [AuthorName], [ApplicationId], [CauseCodeId], [ResolutionId], [Description], [KeyWords]);

