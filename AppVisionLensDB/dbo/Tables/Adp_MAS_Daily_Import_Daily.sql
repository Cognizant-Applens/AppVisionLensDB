CREATE TABLE [dbo].[Adp_MAS_Daily_Import_Daily] (
    [COG_ESAPROJECTID]      VARCHAR (3000)  NULL,
    [MAINSPRING_PROJECT_ID] INT             NULL,
    [PROJECTCODE]           VARCHAR (200)   NULL,
    [PROJECTNAME]           VARCHAR (100)   NULL,
    [DayCount]              BIGINT          NULL,
    [EFFORT_DATE]           DATE            NULL,
    [EFFORT]                NUMERIC (38, 2) NULL
);

