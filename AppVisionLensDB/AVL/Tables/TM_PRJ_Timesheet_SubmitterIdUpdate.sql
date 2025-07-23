CREATE TABLE [AVL].[TM_PRJ_Timesheet_SubmitterIdUpdate] (
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
    [IsNonTicket]       BIT            NULL
);

