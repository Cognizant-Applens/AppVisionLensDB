CREATE TABLE [MS].[MAP_ProjectStartDate_Mapping] (
    [ID]               BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]        INT           NULL,
    [ESAProjectID]     NVARCHAR (50) NULL,
    [ProjectStartDate] DATETIME      NULL,
    [isdeleted]        BIT           NULL,
    CONSTRAINT [PK_ProjectStartDate_Mapping] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);

