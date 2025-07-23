CREATE TYPE [AVL].[AVL_ApproveUnfreezeTimesheet] AS TABLE (
    [EmployeeID]    NVARCHAR (50)  NULL,
    [TimeSheetDate] DATETIME       NULL,
    [TimesheetId]   INT            NULL,
    [IsApproval]    BIT            NULL,
    [StatusId]      INT            NULL,
    [SubmitterID]   NVARCHAR (50)  NULL,
    [Comments]      NVARCHAR (100) NULL);

