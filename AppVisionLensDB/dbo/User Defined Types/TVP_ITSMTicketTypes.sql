CREATE TYPE [dbo].[TVP_ITSMTicketTypes] AS TABLE (
    [TicketTypeName]      NVARCHAR (500) NULL,
    [TicketTypeID]        INT            NULL,
    [IsDebtApplicable]    VARCHAR (20)   NULL,
    [AppLensTicketType]   INT            NULL,
    [AVMServiceMapping]   NVARCHAR (500) NULL,
    [IsDefaultTicketType] VARCHAR (20)   NULL);

