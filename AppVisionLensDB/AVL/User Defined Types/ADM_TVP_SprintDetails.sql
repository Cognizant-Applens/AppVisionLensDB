CREATE TYPE [AVL].[ADM_TVP_SprintDetails] AS TABLE (
    [SprintName]        VARCHAR (1000) NULL,
    [SprintDescription] VARCHAR (4000) NULL,
    [StartDate]         DATETIME       NULL,
    [EndDate]           DATETIME       NULL,
    [Owner]             NVARCHAR (MAX) NULL,
    [Status]            NVARCHAR (20)  NULL,
    [PodId]             INT            NULL,
    [ReleaseDetailsId]  BIGINT         NULL);

