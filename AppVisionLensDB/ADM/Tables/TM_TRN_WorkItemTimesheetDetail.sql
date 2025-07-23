CREATE TABLE [ADM].[TM_TRN_WorkItemTimesheetDetail] (
    [TimesheetDetailID]   BIGINT         IDENTITY (1, 1) NOT NULL,
    [TimeSheetId]         BIGINT         NOT NULL,
    [WorkItemDetailsId]   BIGINT         NULL,
    [ServiceID]           INT            NULL,
    [ActivityID]          INT            NULL,
    [Hours]               DECIMAL (5, 2) NULL,
    [IsNonTicket]         BIT            NOT NULL,
    [SuggestedActivityID] BIGINT         NULL,
    [Remarks]             NVARCHAR (250) NULL,
    [IsDeleted]           BIT            NOT NULL,
    [CreatedBy]           NVARCHAR (50)  NOT NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [ModifiedBy]          NVARCHAR (50)  NULL,
    [ModifiedDate]        DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([TimesheetDetailID] ASC),
    FOREIGN KEY ([ServiceID]) REFERENCES [AVL].[TK_MAS_Service] ([ServiceID]),
    FOREIGN KEY ([SuggestedActivityID]) REFERENCES [AVL].[TM_NonDeliverySuggestedActivity] ([SuggestedActivityID]),
    FOREIGN KEY ([TimeSheetId]) REFERENCES [AVL].[TM_PRJ_Timesheet] ([TimesheetId]),
    FOREIGN KEY ([WorkItemDetailsId]) REFERENCES [ADM].[ALM_TRN_WorkItem_Details] ([WorkItemDetailsId])
);


GO
CREATE NONCLUSTERED INDEX [NCI_WorkItemTimesheetDetail_IsNonTicket_IsDeleted]
    ON [ADM].[TM_TRN_WorkItemTimesheetDetail]([IsNonTicket] ASC, [IsDeleted] ASC)
    INCLUDE([TimeSheetId], [Hours]);


GO
CREATE NONCLUSTERED INDEX [NCI_WorkItemTimesheetDetail_TimeSheetId_IsNonTicket_IsDeleted]
    ON [ADM].[TM_TRN_WorkItemTimesheetDetail]([TimeSheetId] ASC, [IsNonTicket] ASC, [IsDeleted] ASC)
    INCLUDE([Hours]);


GO
CREATE NONCLUSTERED INDEX [IX_TM_TRN_WorkItemTimesheetDetail_ActivityID_IsNonTicket_IsDeleted]
    ON [ADM].[TM_TRN_WorkItemTimesheetDetail]([ActivityID] ASC, [IsNonTicket] ASC, [IsDeleted] ASC)
    INCLUDE([TimesheetDetailID], [Hours]);


GO
CREATE NONCLUSTERED INDEX [IX_TM_TRN_WorkItemTimesheetDetail_TimesheetId_IsDeleted]
    ON [ADM].[TM_TRN_WorkItemTimesheetDetail]([TimeSheetId] ASC, [IsDeleted] ASC)
    INCLUDE([Hours]);


GO
CREATE NONCLUSTERED INDEX [NCI_WorkItemTimesheetDetail_TimeSheetId_WorkItemDetailsId_IsDeleted]
    ON [ADM].[TM_TRN_WorkItemTimesheetDetail]([TimeSheetId] ASC, [WorkItemDetailsId] ASC, [IsDeleted] ASC)
    INCLUDE([TimesheetDetailID], [ServiceID], [ActivityID], [Hours], [IsNonTicket]);


GO
CREATE NONCLUSTERED INDEX [TimeSheetId_TM_PRJ_Timesheet]
    ON [ADM].[TM_TRN_WorkItemTimesheetDetail]([TimeSheetId] ASC);

