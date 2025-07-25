﻿CREATE TABLE [MS].[TRN_APPLENStoMainspringProjectOutBoundData_Monthly] (
    [PROJECTNAME]              NVARCHAR (200)  NULL,
    [DARTProjectID]            INT             NULL,
    [PROJECTID]                NVARCHAR (50)   NOT NULL,
    [ReportingMonthStartDate]  DATETIME        NULL,
    [ReportingMonthEndDate]    DATETIME        NULL,
    [PublishedDate]            DATETIME        NULL,
    [ServiceOfferingLevel2]    NVARCHAR (200)  NULL,
    [ServiceOfferingLevel3]    NVARCHAR (200)  NULL,
    [MetricName]               NVARCHAR (200)  NULL,
    [SupportCategory]          NVARCHAR (200)  NULL,
    [Priority]                 NVARCHAR (200)  NULL,
    [Technology]               NVARCHAR (200)  NULL,
    [Mandatory]                NVARCHAR (200)  NULL,
    [MetricUOM]                NVARCHAR (200)  NULL,
    [APPLICABILITY]            NVARCHAR (200)  NULL,
    [Numerator1Name]           NVARCHAR (200)  NULL,
    [Numerator1Value]          NVARCHAR (200)  NULL,
    [Numerator2Name]           NVARCHAR (200)  NULL,
    [Numerator2Value]          NVARCHAR (200)  NULL,
    [Numerator3Name]           NVARCHAR (200)  NULL,
    [Numerator3Value]          NVARCHAR (200)  NULL,
    [Numerator4Name]           NVARCHAR (200)  NULL,
    [Numerator4Value]          NVARCHAR (200)  NULL,
    [Denominator1Name]         NVARCHAR (200)  NULL,
    [Denominator1Value]        NVARCHAR (200)  NULL,
    [Denominator2Name]         NVARCHAR (200)  NULL,
    [Denominator2Value]        NVARCHAR (200)  NULL,
    [Denominator3Name]         NVARCHAR (200)  NULL,
    [Denominator3Value]        NVARCHAR (200)  NULL,
    [Denominator4Name]         NVARCHAR (200)  NULL,
    [Denominator4Value]        NVARCHAR (200)  NULL,
    [CustomMetricValue]        NVARCHAR (200)  NULL,
    [UniqueName]               NVARCHAR (2000) NOT NULL,
    [FrequencyID]              INT             NOT NULL,
    [ReportPeriodID]           INT             NOT NULL,
    [JobID]                    BIGINT          NULL,
    [GoalType]                 NVARCHAR (50)   NULL,
    [BaselineDate]             DATETIME        NULL,
    [DN_BIC]                   NVARCHAR (200)  NULL,
    [DN_GOAL]                  NVARCHAR (200)  NULL,
    [DN_METRICTYPE]            NVARCHAR (200)  NULL,
    [DN_CPKGOAL]               NVARCHAR (200)  NULL,
    [DN_MINIMUMSERVICETARGET]  NVARCHAR (200)  NULL,
    [DN_EXPECTEDSERVICETARGET] NVARCHAR (200)  NULL,
    [DN_GOALLEVEL]             NVARCHAR (200)  NULL
);

