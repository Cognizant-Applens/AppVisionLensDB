CREATE TABLE [AVL].[TM_TRN_InfraTimesheetDetail] (
    [TimeSheetDetailId]   BIGINT         IDENTITY (1, 1) NOT NULL,
    [TimesheetId]         BIGINT         NULL,
    [TimeTickerID]        BIGINT         NULL,
    [TowerID]             BIGINT         NULL,
    [TicketID]            NVARCHAR (100) NULL,
    [IsNonTicket]         BIT            NULL,
    [TaskId]              INT            NULL,
    [TicketTypeMapID]     INT            NULL,
    [Hours]               DECIMAL (5, 2) NULL,
    [Remarks]             NVARCHAR (MAX) NULL,
    [ProjectId]           BIGINT         NULL,
    [IsDeleted]           BIT            NULL,
    [CreatedBy]           NVARCHAR (50)  NULL,
    [CreatedDateTime]     DATETIME       NULL,
    [ModifiedBy]          NVARCHAR (50)  NULL,
    [ModifiedDateTime]    DATETIME       NULL,
    [SuggestedActivityID] BIGINT         NULL
);


GO
CREATE NONCLUSTERED INDEX [NC_TM_TRN_InfraTimesheetDetail_TimesheetId_IsNonTicket]
    ON [AVL].[TM_TRN_InfraTimesheetDetail]([IsNonTicket] ASC)
    INCLUDE([TimeSheetDetailId], [TimesheetId], [TimeTickerID], [TicketID], [TaskId], [Hours], [ProjectId], [IsDeleted]);


GO
CREATE NONCLUSTERED INDEX [NC_TM_TRN_InfraTimesheetDetail_TimesheetId_ProjectId]
    ON [AVL].[TM_TRN_InfraTimesheetDetail]([TimesheetId] ASC, [ProjectId] ASC)
    INCLUDE([TimeSheetDetailId], [TimeTickerID], [TicketID], [IsNonTicket], [TaskId], [Hours], [IsDeleted]);


GO
CREATE NONCLUSTERED INDEX [IX_TM_TRN_InfraTimesheetDetail_TimesheetId_ProjectId_IsDeleted]
    ON [AVL].[TM_TRN_InfraTimesheetDetail]([TimesheetId] ASC, [ProjectId] ASC, [IsDeleted] ASC)
    INCLUDE([Hours]);


GO
CREATE NONCLUSTERED INDEX [IX_TM_TRN_InfraTimesheetDetail_TimesheetId_ProjectId_IsDeleted_TaskId_IsNonTicket]
    ON [AVL].[TM_TRN_InfraTimesheetDetail]([TimesheetId] ASC, [ProjectId] ASC, [IsDeleted] ASC, [TaskId] ASC, [IsNonTicket] ASC)
    INCLUDE([TimeSheetDetailId], [TicketID], [Hours], [TimeTickerID]);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20210808-185438]
    ON [AVL].[TM_TRN_InfraTimesheetDetail]([TimesheetId] ASC, [IsNonTicket] ASC, [ProjectId] ASC, [IsDeleted] ASC)
    INCLUDE([TimeSheetDetailId], [TicketID], [Hours], [TimeTickerID], [TaskId]);

