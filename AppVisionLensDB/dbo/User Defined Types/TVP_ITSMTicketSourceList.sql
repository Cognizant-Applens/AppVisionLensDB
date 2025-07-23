CREATE TYPE [dbo].[TVP_ITSMTicketSourceList] AS TABLE (
    [SourceID]        INT            NULL,
    [SourceName]      NVARCHAR (500) NULL,
    [IsDefaultSource] NVARCHAR (20)  NULL,
    [SourceIDMapID]   INT            NULL);

