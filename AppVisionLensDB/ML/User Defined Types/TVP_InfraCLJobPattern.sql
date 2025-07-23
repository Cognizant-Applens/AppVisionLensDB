CREATE TYPE [ML].[TVP_InfraCLJobPattern] AS TABLE (
    [TowerName]             NVARCHAR (500)  NULL,
    [CauseCode]             NVARCHAR (1000) NULL,
    [ResolutionCode]        NVARCHAR (1000) NULL,
    [Desc_Base_WorkPattern] NVARCHAR (1000) NULL,
    [Desc_Sub_WorkPattern]  NVARCHAR (1000) NULL,
    [Res_Base_WorkPattern]  NVARCHAR (1000) NULL,
    [Res_Sub_WorkPattern]   NVARCHAR (1000) NULL,
    [MLDebtClassification]  NVARCHAR (500)  NULL,
    [MLAvoidableFlag]       NVARCHAR (500)  NULL,
    [MLResidualDebt]        NVARCHAR (500)  NULL,
    [TicketOccurence]       INT             NULL,
    [MLRuleAccuracy]        NVARCHAR (500)  NULL,
    [SMEApproval]           NVARCHAR (500)  NULL);

