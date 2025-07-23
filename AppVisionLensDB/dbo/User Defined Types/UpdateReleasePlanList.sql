CREATE TYPE [dbo].[UpdateReleasePlanList] AS TABLE (
    [ProjectID]     INT             NULL,
    [TicketID]      NVARCHAR (100)  NULL,
    [EmployeeID]    NVARCHAR (100)  NULL,
    [PriorityID]    INT             NULL,
    [HealTypeID]    INT             NULL,
    [PlannedEffort] DECIMAL (18, 2) NULL);

