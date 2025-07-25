﻿CREATE TABLE [LW].[RuleStatistics] (
    [ID]                          BIGINT        IDENTITY (1, 1) NOT NULL,
    [DeliveryBidFlag]             VARCHAR (10)  NOT NULL,
    [MonthYear]                   VARCHAR (20)  NOT NULL,
    [AccountID]                   BIGINT        NOT NULL,
    [AccountName]                 VARCHAR (100) NOT NULL,
    [BUID]                        SMALLINT      NOT NULL,
    [BUName]                      VARCHAR (100) NOT NULL,
    [PendingRulesCount]           BIGINT        NOT NULL,
    [ApprovedRulesCount]          BIGINT        NOT NULL,
    [OverriddenRulesCount]        BIGINT        NOT NULL,
    [DormantRulesCount]           BIGINT        NOT NULL,
    [MutedRulesCount]             BIGINT        NOT NULL,
    [TotalRulesCount]             BIGINT        NOT NULL,
    [AutoclassifiedTicketCount]   BIGINT        NOT NULL,
    [ManualclassifiedTicketCount] BIGINT        NOT NULL,
    [OverriddenTicketCount]       BIGINT        NOT NULL,
    [UnclassifiedTicketCount]     BIGINT        NOT NULL,
    [DDclassifiedTicketCount]     BIGINT        NOT NULL,
    [TotalTicketCount]            BIGINT        NOT NULL,
    [IsActive]                    SMALLINT      NOT NULL,
    [DeliveryOnpremiseInd]        NVARCHAR (20) NOT NULL,
    [CreatedDate]                 DATETIME      NOT NULL,
    [CreatedBy]                   NVARCHAR (50) NOT NULL,
    [ModifiedDate]                DATETIME      NULL,
    [ModifiedBy]                  NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

