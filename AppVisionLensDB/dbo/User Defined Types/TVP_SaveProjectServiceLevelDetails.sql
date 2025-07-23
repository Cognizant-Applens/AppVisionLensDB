CREATE TYPE [dbo].[TVP_SaveProjectServiceLevelDetails] AS TABLE (
    [EmployeeID]     NVARCHAR (100) NULL,
    [CustomerID]     NVARCHAR (100) NULL,
    [ServiceLevelID] NVARCHAR (100) NULL,
    [ProjectID]      NVARCHAR (100) NULL,
    [IsESAAllocated] INT            NULL);

