CREATE TYPE [dbo].[TVP_UpdateUserManagementDetailsTemp] AS TABLE (
    [EmployeeID]             NVARCHAR (100) NULL,
    [EmployeeName]           NVARCHAR (100) NULL,
    [ClientUserID]           NVARCHAR (100) NULL,
    [CustomerID]             NVARCHAR (100) NULL,
    [TimezoneID]             INT            NULL,
    [LocationID]             INT            NULL,
    [TSApproverID]           NVARCHAR (100) NULL,
    [TicketingModuleEnabled] NVARCHAR (100) NULL);

