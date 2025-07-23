CREATE TYPE [dbo].[TVP_ProjectDataDictionary_Delete] AS TABLE (
    [ID]               INT NOT NULL,
    [ProjectID]        INT NOT NULL,
    [ApplicationID]    INT NULL,
    [CauseCodeID]      INT NULL,
    [ResolutionCodeID] INT NULL);

