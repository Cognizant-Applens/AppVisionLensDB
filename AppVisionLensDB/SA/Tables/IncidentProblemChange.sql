CREATE TABLE [SA].[IncidentProblemChange] (
    [IncidentProblemChangeId]                  INT            IDENTITY (1, 1) NOT NULL,
    [IncidentProblemChangeIncidentNumber]      NVARCHAR (15)  DEFAULT (NULL) NULL,
    [IncidentProblemChangeProblemNumber]       NVARCHAR (100) DEFAULT (NULL) NULL,
    [IncidentProblemChangeChangeRequestNumber] NVARCHAR (100) DEFAULT (NULL) NULL,
    [IncidentProblemChangeImpact]              NVARCHAR (100) DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([IncidentProblemChangeId] ASC)
);

