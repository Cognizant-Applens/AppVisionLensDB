CREATE TYPE [AVL].[DebtUnclassifiedTicketDetails] AS TABLE (
    [TicketId]               NVARCHAR (100) NOT NULL,
    [CauseCode]              NVARCHAR (500) NOT NULL,
    [ResolutionCode]         NVARCHAR (500) NOT NULL,
    [DebtClassificationName] NVARCHAR (50)  NOT NULL,
    [AvoidableFlag]          NVARCHAR (50)  NOT NULL,
    [ResiDualDebt]           NVARCHAR (50)  NOT NULL,
    [FlexField1]             NVARCHAR (MAX) NULL,
    [FlexField2]             NVARCHAR (MAX) NULL,
    [FlexField3]             NVARCHAR (MAX) NULL,
    [FlexField4]             NVARCHAR (MAX) NULL);

