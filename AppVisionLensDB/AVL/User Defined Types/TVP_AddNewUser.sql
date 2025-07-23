CREATE TYPE [AVL].[TVP_AddNewUser] AS TABLE (
    [EmployeeID]     NVARCHAR (100) NULL,
    [EmployeeName]   NVARCHAR (100) NULL,
    [EmployeeEmail]  NVARCHAR (100) NULL,
    [ClientUserID]   NVARCHAR (100) NULL,
    [CustomerID]     NVARCHAR (100) NULL,
    [TimezoneID]     INT            NULL,
    [TimeZoneName]   NVARCHAR (100) NULL,
    [TSApproverID]   NVARCHAR (100) NULL,
    [MandatoryHours] DECIMAL (6, 2) NULL,
    [IsDeleted]      BIT            NULL,
    [UserID]         BIGINT         NULL);

