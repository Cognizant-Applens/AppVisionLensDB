CREATE TABLE [MS].[TRN_Job_Log] (
    [ID]                    BIGINT         IDENTITY (1, 1) NOT NULL,
    [JOBNAME]               NVARCHAR (100) NULL,
    [ActivityHide]          INT            NULL,
    [StandardActivityAdded] INT            NULL,
    [CustomActivityAdded]   INT            NULL,
    [JobrunDate]            DATETIME       NULL,
    CONSTRAINT [PK_Job_Log] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);

