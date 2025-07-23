CREATE TABLE [SA].[CriticalProcessTransaction] (
    [Id]                 INT            IDENTITY (1, 1) NOT NULL,
    [StageId]            INT            NOT NULL,
    [ProcessedDate]      DATETIME       NOT NULL,
    [ActualStartTime]    DATETIME       NULL,
    [ActualEndTime]      DATETIME       NULL,
    [DurationMinutes]    INT            NULL,
    [ActualCount]        INT            NULL,
    [Status]             NVARCHAR (100) NOT NULL,
    [ProcessedDateKey]   INT            NULL,
    [ActualStartTimeKey] INT            NULL,
    [ActualEndTimeKey]   INT            NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80)
);

