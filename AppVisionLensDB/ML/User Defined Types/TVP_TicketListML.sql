CREATE TYPE [ML].[TVP_TicketListML] AS TABLE (
    [BatchProcessId]     BIGINT         NULL,
    [TicketId]           NVARCHAR (50)  NOT NULL,
    [ProjectID]          BIGINT         NOT NULL,
    [TicketDescription]  NVARCHAR (MAX) NULL,
    [AdditionalText]     NVARCHAR (MAX) NULL,
    [AdditionalTextFlag] NVARCHAR (MAX) NULL);

