CREATE TYPE [dbo].[TVP_EffortTimesheetTicketDetailsSubmit] AS TABLE (
    [TicketId]          NVARCHAR (MAX) NULL,
    [ProjectID]         BIGINT         NULL,
    [ApplicationID]     BIGINT         NULL,
    [ServiceID]         BIGINT         NULL,
    [CategoryID]        BIGINT         NULL,
    [ActivityID]        BIGINT         NULL,
    [StatusID]          BIGINT         NULL,
    [SubmitterID]       INT            NULL,
    [TimeSheetDate]     DATETIME       NULL,
    [EffortHours]       DECIMAL (18)   NULL,
    [IsNonTicket]       NVARCHAR (10)  NULL,
    [TimesheetId]       NVARCHAR (MAX) NULL,
    [TimeSheetDetailId] NVARCHAR (MAX) NULL);

