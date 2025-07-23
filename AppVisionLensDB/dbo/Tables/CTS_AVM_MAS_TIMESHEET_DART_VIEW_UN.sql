CREATE TABLE [dbo].[CTS_AVM_MAS_TIMESHEET_DART_VIEW_UN] (
    [Project Name]     VARCHAR (100)   NULL,
    [ESA ProjectID]    VARCHAR (200)   NULL,
    [Task ID]          VARCHAR (40)    NULL,
    [Application]      VARCHAR (2000)  NULL,
    [Service Name]     VARCHAR (1000)  NULL,
    [Phase]            VARCHAR (200)   NULL,
    [Activity]         VARCHAR (2000)  NULL,
    [Standad Activity] VARCHAR (200)   NULL,
    [Hours]            NUMERIC (38, 2) NOT NULL,
    [Submitter ID]     VARCHAR (100)   NULL,
    [Submitter Name]   VARCHAR (201)   NULL,
    [Submitted Date]   DATETIME        NULL
);

