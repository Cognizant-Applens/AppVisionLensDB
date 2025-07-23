CREATE TABLE [AVL].[TM_TRN_TimesheetDetail] (
    [TimeSheetDetailId]   BIGINT         IDENTITY (1, 1) NOT NULL,
    [TimesheetId]         BIGINT         NULL,
    [TimeTickerID]        BIGINT         NULL,
    [ApplicationID]       BIGINT         NULL,
    [TicketID]            NVARCHAR (100) NULL,
    [ShiftId]             INT            NULL,
    [IsNonTicket]         BIT            NULL,
    [ServiceId]           INT            NULL,
    [CategoryId]          INT            NULL,
    [ActivityId]          INT            NULL,
    [TicketTypeMapID]     INT            NULL,
    [Hours]               DECIMAL (5, 2) NULL,
    [Remarks]             NVARCHAR (MAX) NULL,
    [IsAttributeUpdated]  BIT            NULL,
    [TicketSourceID]      NVARCHAR (100) NULL,
    [IsSDTicket]          BIT            NULL,
    [ProjectId]           BIGINT         NULL,
    [IsDeleted]           BIT            NULL,
    [CreatedBy]           NVARCHAR (50)  NULL,
    [CreatedDateTime]     DATETIME       NULL,
    [ModifiedBy]          NVARCHAR (50)  NULL,
    [ModifiedDateTime]    DATETIME       NULL,
    [SuggestedActivityID] BIGINT         NULL,
    CONSTRAINT [PK_TimeSheetDetailId] PRIMARY KEY NONCLUSTERED ([TimeSheetDetailId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TM_TRN_TimesheetDetail_TicketID_ProjectId]
    ON [AVL].[TM_TRN_TimesheetDetail]([TicketID] ASC, [ProjectId] ASC)
    INCLUDE([Hours], [IsDeleted]);


GO
CREATE NONCLUSTERED INDEX [IX_TM_TRN__TimesheetDetail_TimesheetId_ProjectId_IsDeleted]
    ON [AVL].[TM_TRN_TimesheetDetail]([TimesheetId] ASC, [ProjectId] ASC, [IsDeleted] ASC)
    INCLUDE([Hours]);


GO
CREATE NONCLUSTERED INDEX [IX_TM_TRN_TimesheetDetail_ProjectId_TimesheetId_IsDeleted_IsNonTicket]
    ON [AVL].[TM_TRN_TimesheetDetail]([ProjectId] ASC, [TimesheetId] ASC, [IsDeleted] ASC, [IsNonTicket] ASC)
    INCLUDE([TimeSheetDetailId], [TicketID], [ServiceId], [Hours], [TimeTickerID], [ActivityId]);


GO
CREATE NONCLUSTERED INDEX [IX_TM_TRN_TimesheetDetail_TimesheetId_ProjectId_IsDeleted_ActivityId_IsNonTicket]
    ON [AVL].[TM_TRN_TimesheetDetail]([TimesheetId] ASC, [ProjectId] ASC, [IsDeleted] ASC, [ActivityId] ASC, [IsNonTicket] ASC)
    INCLUDE([TimeSheetDetailId], [TicketID], [Hours], [TimeTickerID]);


GO
CREATE NONCLUSTERED INDEX [NCI_TimesheetDetail_TimesheetId_IsDeleted]
    ON [AVL].[TM_TRN_TimesheetDetail]([TimesheetId] ASC, [IsDeleted] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-TimesheetID_TicketID]
    ON [AVL].[TM_TRN_TimesheetDetail]([TimesheetId] ASC, [TimeTickerID] ASC, [TicketID] ASC);

