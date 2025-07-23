CREATE TABLE [SA].[BusinessCriticalityMaster] (
    [BusinessCriticalityId] INT           IDENTITY (1, 1) NOT NULL,
    [ApplicationId]         BIGINT        NOT NULL,
    [BusinessName]          VARCHAR (100) DEFAULT (NULL) NULL,
    [BusinessArea]          VARCHAR (100) NOT NULL,
    [BusinessCriticality]   VARCHAR (100) DEFAULT (NULL) NULL,
    [SourceFileIssues]      INT           DEFAULT (NULL) NULL,
    [Connectivity]          INT           DEFAULT (NULL) NULL,
    [Performance]           INT           DEFAULT (NULL) NULL,
    [NewApplication]        INT           DEFAULT (NULL) NULL,
    [DataQuality]           INT           DEFAULT (NULL) NULL,
    [Volume]                INT           DEFAULT (NULL) NULL,
    [EndOfTerm]             INT           DEFAULT (NULL) NULL,
    [FileDelay]             INT           DEFAULT (NULL) NULL,
    [NoSourceFile]          INT           DEFAULT (NULL) NULL,
    [DownstreamImpact]      INT           DEFAULT (NULL) NULL,
    [FinalCriticallity]     INT           DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([BusinessCriticalityId] ASC)
);

