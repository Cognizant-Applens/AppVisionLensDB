CREATE TYPE [dbo].[TVP_UpdateReleasePlanList] AS TABLE (
    [ProjectID]     INT            NULL,
    [TicketID]      NVARCHAR (100) NULL,
    [EmployeeID]    NVARCHAR (100) NULL,
    [ReleasePlanID] INT            NULL,
    [AssigneeID]    VARCHAR (20)   NULL);

