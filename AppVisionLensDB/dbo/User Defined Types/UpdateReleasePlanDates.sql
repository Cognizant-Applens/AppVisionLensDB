CREATE TYPE [dbo].[UpdateReleasePlanDates] AS TABLE (
    [ProjectID]        INT            NULL,
    [HealTicketId]     NVARCHAR (100) NULL,
    [PlannedStartDate] DATETIME       NULL,
    [PlannedEndDate]   DATETIME       NULL,
    [ReleasePlanning]  VARCHAR (100)  NULL,
    [EmployeeID]       VARCHAR (100)  NULL);

