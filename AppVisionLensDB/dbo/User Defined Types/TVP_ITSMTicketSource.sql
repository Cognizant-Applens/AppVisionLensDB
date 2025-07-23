CREATE TYPE [dbo].[TVP_ITSMTicketSource] AS TABLE (
    [SourceName]      NVARCHAR (500) NULL,
    [SourceID]        INT            NULL,
    [IsDefaultSource] NVARCHAR (20)  NULL);

