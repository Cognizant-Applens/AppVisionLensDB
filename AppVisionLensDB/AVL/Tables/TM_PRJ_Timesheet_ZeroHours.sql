CREATE TABLE [AVL].[TM_PRJ_Timesheet_ZeroHours] (
    [TimesheetDetailID] BIGINT         NOT NULL,
    [TimesheetDate]     DATE           NOT NULL,
    [Hours]             DECIMAL (5, 2) NULL,
    [StatusID]          NUMERIC (6)    NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL
);

