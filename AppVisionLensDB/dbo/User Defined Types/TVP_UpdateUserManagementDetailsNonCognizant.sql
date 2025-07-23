CREATE TYPE [dbo].[TVP_UpdateUserManagementDetailsNonCognizant] AS TABLE (
    [EmployeeID]     NVARCHAR (100) NULL,
    [EmployeeName]   NVARCHAR (100) NULL,
    [ClientUserID]   NVARCHAR (100) NULL,
    [CustomerID]     NVARCHAR (100) NULL,
    [TimezoneID]     INT            NULL,
    [LocationID]     INT            NULL,
    [TSApproverID]   NVARCHAR (100) NULL,
    [MandatoryHours] DECIMAL (6, 2) NULL,
    [IsDeleted]      BIT            NULL,
    [PODDetailID]    VARCHAR (100)  NULL,
    [RoleID]         INT            NULL);

