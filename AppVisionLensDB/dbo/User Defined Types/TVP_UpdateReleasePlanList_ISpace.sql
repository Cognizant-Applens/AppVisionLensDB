CREATE TYPE [dbo].[TVP_UpdateReleasePlanList_ISpace] AS TABLE (
    [ProjectID]        INT            NULL,
    [TicketID]         NVARCHAR (100) NULL,
    [EmployeeID]       NVARCHAR (100) NULL,
    [ReleasePlanID]    INT            NULL,
    [AssigneeID]       VARCHAR (20)   NULL,
    [IsMapped]         INT            NULL,
    [PlannedStartDate] DATETIME       NULL,
    [PlannedEndDate]   DATETIME       NULL);

