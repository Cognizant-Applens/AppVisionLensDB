CREATE TABLE [MS].[MAP_ProjectPriority_Mapping] (
    [MainSpringProjectPriorityID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ESAProjectID]                NVARCHAR (50) NULL,
    [PriorityID]                  INT           NULL,
    [IsDeleted]                   INT           NULL,
    CONSTRAINT [PK_MainspringProjectPriority_Mapping] PRIMARY KEY CLUSTERED ([MainSpringProjectPriorityID] ASC) WITH (FILLFACTOR = 70)
);

