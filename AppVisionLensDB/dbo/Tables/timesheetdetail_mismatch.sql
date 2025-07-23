CREATE TABLE [dbo].[timesheetdetail_mismatch] (
    [ticket id]      NVARCHAR (500) NULL,
    [projectid]      BIGINT         NOT NULL,
    [associate id]   NVARCHAR (500) NULL,
    [timesheet date] NVARCHAR (500) NULL
);

