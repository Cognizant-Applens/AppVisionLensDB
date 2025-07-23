CREATE TABLE [MS].[MAS_Priority_Master] (
    [MainspringPriorityID]   INT           IDENTITY (1, 1) NOT NULL,
    [MainspringPriorityName] VARCHAR (200) NULL,
    [IsDeleted]              BIT           NULL,
    CONSTRAINT [PK_Mainspring_Priority_Master] PRIMARY KEY CLUSTERED ([MainspringPriorityID] ASC) WITH (FILLFACTOR = 70)
);

