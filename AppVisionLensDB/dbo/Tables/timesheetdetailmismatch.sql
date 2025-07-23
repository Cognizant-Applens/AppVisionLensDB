CREATE TABLE [dbo].[timesheetdetailmismatch] (
    [ticket id]      NVARCHAR (500) NULL,
    [projectid]      BIGINT         NOT NULL,
    [associate id]   NVARCHAR (500) NULL,
    [timesheet date] NVARCHAR (500) NULL,
    [project id]     NVARCHAR (500) NULL,
    [activity]       NVARCHAR (500) NULL,
    [hours]          NVARCHAR (500) NULL,
    [Remarks]        NVARCHAR (500) NULL,
    [timetickerid]   BIGINT         NULL,
    [TimesheetId]    BIGINT         NULL
);

