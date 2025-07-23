CREATE TYPE [dbo].[UpdateApproveTicketList] AS TABLE (
    [TicketID]                NVARCHAR (100) NULL,
    [DebtClassificationMapID] INT            NULL,
    [ResolutionCodeMapID]     INT            NULL,
    [CauseCodeMapID]          INT            NULL,
    [ResidualDebtMapID]       INT            NULL,
    [AvoidableFlag]           INT            NULL,
    [AssignedTo]              NVARCHAR (100) NULL,
    [FlexField1]              NVARCHAR (500) NULL,
    [FlexField2]              NVARCHAR (500) NULL,
    [FlexField3]              NVARCHAR (500) NULL,
    [FlexField4]              NVARCHAR (500) NULL,
    [EmployeeID]              NVARCHAR (50)  NULL,
    [IsFlexField1Modified]    NVARCHAR (20)  NULL,
    [IsFlexField2Modified]    NVARCHAR (20)  NULL,
    [IsFlexField3Modified]    NVARCHAR (20)  NULL,
    [IsFlexField4Modified]    NVARCHAR (20)  NULL);

