﻿CREATE TABLE [SA].[CriticalProcessMaster] (
    [CriticalProcessId]               INT            IDENTITY (1, 1) NOT NULL,
    [CriticalProcessApplicationId]    BIGINT         NOT NULL,
    [CriticalProcessBusinessName]     NVARCHAR (100) NOT NULL,
    [CriticalProcessBusinessArea]     NVARCHAR (100) NULL,
    [CriticalProcessStageName]        NVARCHAR (100) NULL,
    [CriticalProcessStageType]        NVARCHAR (100) NULL,
    [CriticalProcessStartTime]        TIME (7)       NULL,
    [CriticalProcessEndTime]          TIME (7)       NULL,
    [CriticalProcessExpectedDuration] INT            NULL,
    [OrderOfExecution]                INT            NULL,
    [Dependency]                      TINYINT        NULL,
    [LogFileName]                     NVARCHAR (100) NULL,
    [LogFilePath]                     NVARCHAR (100) NULL,
    [CriticalProcessRemark]           NVARCHAR (100) NULL,
    [DisplayName]                     NVARCHAR (100) NOT NULL,
    [PercentageCompletion]            INT            NOT NULL,
    [CriticalProcessComplexity]       NVARCHAR (100) NOT NULL,
    [CriticalExpectedCount]           INT            NOT NULL,
    [CriticalMinimumCount]            INT            NOT NULL,
    [CriticalMaximumCount]            INT            NOT NULL,
    [DependencyStep]                  NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([CriticalProcessId] ASC)
);

