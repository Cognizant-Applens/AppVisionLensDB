CREATE TYPE [dbo].[TVP_CustomerEffortTimesheetDetailsSubmit1] AS TABLE (
    [TicketId]           NVARCHAR (MAX) NULL,
    [ProjectID]          BIGINT         NULL,
    [ApplicationID]      BIGINT         NULL,
    [TicketTypeMapID]    BIGINT         NULL,
    [StatusID]           BIGINT         NULL,
    [SubmitterID]        INT            NULL,
    [TimeSheetDate]      DATETIME       NULL,
    [EffortHours]        DECIMAL (18)   NULL,
    [IsNonTicket]        NVARCHAR (10)  NULL,
    [TimesheetId]        NVARCHAR (MAX) NULL,
    [TimeSheetDetailId]  NVARCHAR (MAX) NULL,
    [IsAttributeUpdated] INT            NULL);

