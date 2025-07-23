CREATE TABLE [AVL].[TM_PRJ_Timesheet] (
    [TimesheetId]       BIGINT         IDENTITY (1, 1) NOT NULL,
    [CustomerID]        BIGINT         NULL,
    [ProjectID]         BIGINT         NULL,
    [SubmitterId]       NVARCHAR (50)  NULL,
    [TimesheetDate]     DATE           NOT NULL,
    [StatusId]          NUMERIC (6)    NULL,
    [ApprovedBy]        NVARCHAR (50)  NULL,
    [UnfreezedBy]       NVARCHAR (50)  NULL,
    [UnfreezedDate]     DATETIME       NULL,
    [CreatedBy]         NVARCHAR (50)  NULL,
    [CreatedDateTime]   DATETIME       NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL,
    [ModifiedDateTime]  DATETIME       NULL,
    [IsAutosubmit]      BIT            NULL,
    [RejectionComments] NVARCHAR (500) NULL,
    [ApprovedDate]      DATETIME       NULL,
    [TSRegion]          NVARCHAR (50)  NULL,
    [IsNonTicket]       BIT            NULL,
    CONSTRAINT [PK__TM_PRJ_T__848CBE2D56BA7216] PRIMARY KEY CLUSTERED ([TimesheetId] ASC),
    CONSTRAINT [FK_TM_PRJ_Timesheet_MAS_ProjectMaster] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_TM_PRJ_Timesheet_TimesheetDate]
    ON [AVL].[TM_PRJ_Timesheet]([TimesheetDate] ASC)
    INCLUDE([TimesheetId], [SubmitterId], [StatusId]);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-CustomerID_ProjectID_SubmitterID_TimeSheetDate]
    ON [AVL].[TM_PRJ_Timesheet]([CustomerID] ASC, [ProjectID] ASC, [SubmitterId] ASC, [TimesheetDate] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-CustomerID_SubmitterID_TimeSheetDate_StatusID]
    ON [AVL].[TM_PRJ_Timesheet]([CustomerID] ASC, [SubmitterId] ASC, [TimesheetDate] ASC, [StatusId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TM_PRJ_Timesheet_TimesheetDate]
    ON [AVL].[TM_PRJ_Timesheet]([TimesheetDate] ASC)
    INCLUDE([TimesheetId], [ProjectID]);


GO
CREATE NONCLUSTERED INDEX [IX_TM_PRJ_Timesheet_TimesheetDate_SubmittedId]
    ON [AVL].[TM_PRJ_Timesheet]([TimesheetDate] ASC)
    INCLUDE([TimesheetId], [ProjectID], [SubmitterId]);


GO
CREATE NONCLUSTERED INDEX [TestIndex]
    ON [AVL].[TM_PRJ_Timesheet]([CustomerID] ASC, [TimesheetDate] ASC)
    INCLUDE([SubmitterId], [StatusId]);


GO
CREATE NONCLUSTERED INDEX [Ix_CustomerID_ProjectID_SubmitterID_TimeSheetDate]
    ON [AVL].[TM_PRJ_Timesheet]([CustomerID] ASC, [ProjectID] ASC, [SubmitterId] ASC, [TimesheetDate] ASC);


GO
CREATE NONCLUSTERED INDEX [NC_TM_PRJ_Timesheet_PID_TId_SubmitterId_TDate]
    ON [AVL].[TM_PRJ_Timesheet]([ProjectID] ASC)
    INCLUDE([TimesheetId], [SubmitterId], [TimesheetDate]);


GO
CREATE NONCLUSTERED INDEX [IX_TM_PRJ_Timesheet_CustomerID_ProjectID_SubmitterId]
    ON [AVL].[TM_PRJ_Timesheet]([CustomerID] ASC, [ProjectID] ASC, [SubmitterId] ASC);


GO
CREATE NONCLUSTERED INDEX [Ix_TM_PRJ_Timesheet_SubmitterId_ProjectID_TimesheetId_TimeSheetDate]
    ON [AVL].[TM_PRJ_Timesheet]([SubmitterId] ASC, [ProjectID] ASC, [TimesheetId] ASC, [TimesheetDate] ASC)
    INCLUDE([StatusId]);


GO
CREATE NONCLUSTERED INDEX [Ix_TM_PRJ_Timesheet_SubmitterId_ProjectID_TimesheetId_TimeSheetDate_StatusId]
    ON [AVL].[TM_PRJ_Timesheet]([SubmitterId] ASC, [ProjectID] ASC, [TimesheetId] ASC, [TimesheetDate] ASC, [StatusId] ASC);

