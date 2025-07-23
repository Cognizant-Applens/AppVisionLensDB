CREATE TYPE [ML].[TVP_InfraCLJobTickets] AS TABLE (
    [TicketID]              NVARCHAR (50)   NULL,
    [TowerName]             NVARCHAR (250)  NULL,
    [CauseCode]             NVARCHAR (50)   NULL,
    [ResolutionCode]        NVARCHAR (50)   NULL,
    [DebtClassification]    NVARCHAR (50)   NULL,
    [AvoidableFlag]         NVARCHAR (50)   NULL,
    [ResidualDebt]          NVARCHAR (50)   NULL,
    [Desc_Base_WorkPattern] NVARCHAR (2000) NULL,
    [Desc_Sub_WorkPattern]  NVARCHAR (2000) NULL,
    [Res_Base_WorkPattern]  NVARCHAR (2000) NULL,
    [Res_Sub_WorkPattern]   NVARCHAR (2000) NULL);

