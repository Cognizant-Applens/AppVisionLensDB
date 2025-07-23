CREATE TYPE [dbo].[TVP_ITSMTicketTypes_Apr24] AS TABLE (
    [ID]                    INT            NULL,
    [TicketTypeName]        NVARCHAR (500) NULL,
    [TicketTypeID]          INT            NULL,
    [IsDebtApplicable]      VARCHAR (20)   NULL,
    [AppLensTicketType]     INT            NULL,
    [AVMServiceMappingList] VARCHAR (200)  NULL,
    [IsDefaultTicketType]   VARCHAR (20)   NULL,
    [SupportTypeID]         INT            NULL);

