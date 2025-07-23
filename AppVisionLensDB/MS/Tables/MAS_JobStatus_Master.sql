CREATE TABLE [MS].[MAS_JobStatus_Master] (
    [JobStatusID]   INT           IDENTITY (1, 1) NOT NULL,
    [JobStatusDESC] NVARCHAR (50) NULL,
    CONSTRAINT [PK_JobStatus_Master] PRIMARY KEY CLUSTERED ([JobStatusID] ASC) WITH (FILLFACTOR = 70)
);

