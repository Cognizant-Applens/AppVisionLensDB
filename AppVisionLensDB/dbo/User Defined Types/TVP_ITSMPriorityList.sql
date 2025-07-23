CREATE TYPE [dbo].[TVP_ITSMPriorityList] AS TABLE (
    [PriorityID]           INT           NULL,
    [PriorityIDMapID]      INT           NULL,
    [PriorityName]         VARCHAR (200) NULL,
    [IsDefaultPriority]    VARCHAR (20)  NULL,
    [MainspringPriorityID] INT           NULL);

