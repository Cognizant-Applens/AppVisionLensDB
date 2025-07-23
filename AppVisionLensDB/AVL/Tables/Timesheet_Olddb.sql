CREATE TABLE [AVL].[Timesheet_Olddb] (
    [TimesheetId]   BIGINT        NOT NULL,
    [CustomerID]    BIGINT        NULL,
    [ProjectID]     BIGINT        NULL,
    [SubmitterId]   NVARCHAR (50) NULL,
    [TimesheetDate] DATE          NOT NULL,
    [StatusId]      NUMERIC (6)   NULL
);

