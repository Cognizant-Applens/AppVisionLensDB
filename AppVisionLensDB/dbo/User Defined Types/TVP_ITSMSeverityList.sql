CREATE TYPE [dbo].[TVP_ITSMSeverityList] AS TABLE (
    [SeverityID]        INT           NULL,
    [SeverityIDMapID]   INT           NULL,
    [SeverityName]      VARCHAR (200) NULL,
    [IsDefaultSeverity] VARCHAR (20)  NULL);

