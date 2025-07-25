﻿CREATE TABLE [BCS].[BidRules] (
    [RULE_ID]         BIGINT         NOT NULL,
    [PRIORITY]        BIGINT         NOT NULL,
    [WORK_PATTERN]    NVARCHAR (255) NOT NULL,
    [CAUSE_CODE]      NVARCHAR (255) NOT NULL,
    [RESOLUTION_CODE] NVARCHAR (255) NOT NULL,
    [SERVICE_NAME]    NVARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([RULE_ID] ASC)
);

