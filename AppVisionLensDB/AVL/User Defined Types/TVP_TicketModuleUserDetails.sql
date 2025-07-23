CREATE TYPE [AVL].[TVP_TicketModuleUserDetails] AS TABLE (
    [UserID]                 VARCHAR (10)   NULL,
    [EmployeeID]             VARCHAR (7)    NULL,
    [EmployeeName]           VARCHAR (100)  NULL,
    [ClientUserID]           NVARCHAR (100) NULL,
    [customerID]             NVARCHAR (10)  NULL,
    [TimeZoneName]           VARCHAR (100)  NULL,
    [TSApproverID]           VARCHAR (7)    NULL,
    [TicketingModuleEnabled] VARCHAR (3)    NULL,
    [MandatoryHours]         VARCHAR (10)   NULL,
    [UserServiceLevel1ID]    NVARCHAR (3)   NULL,
    [UserServiceLevel2ID]    NVARCHAR (3)   NULL,
    [UserServiceLevel3ID]    NVARCHAR (3)   NULL,
    [UserServiceLevel4ID]    NVARCHAR (3)   NULL,
    [UserServiceLevelOthers] NVARCHAR (3)   NULL,
    [PODDetails]             NVARCHAR (300) NULL,
    [RoleName]               NVARCHAR (100) NULL);

