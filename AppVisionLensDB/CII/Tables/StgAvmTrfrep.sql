﻿CREATE TABLE [CII].[StgAvmTrfrep] (
    [VerticalName]       VARCHAR (200)  NULL,
    [HorizontalName]     VARCHAR (200)  NULL,
    [SubHorizontalName]  VARCHAR (200)  NULL,
    [ParentCustomerId]   VARCHAR (200)  NULL,
    [AccountName]        VARCHAR (200)  NULL,
    [SubAccountName]     VARCHAR (300)  NULL,
    [ProjectId]          VARCHAR (200)  NULL,
    [ProjectName]        VARCHAR (200)  NULL,
    [GlobalMarket]       VARCHAR (200)  NULL,
    [BusinessName]       VARCHAR (200)  NULL,
    [OpportunityId]      INT            NULL,
    [OpporSubmitter]     VARCHAR (500)  NULL,
    [OpporSubmitterDept] VARCHAR (2500) NULL,
    [OpporCreatedOn]     DATETIME       NULL,
    [Ideaid]             INT            NULL,
    [IdeaTitle]          VARCHAR (500)  NULL,
    [IdeaDesc]           VARCHAR (2500) NULL,
    [SubmitterId]        VARCHAR (200)  NULL,
    [SubmitterName]      VARCHAR (200)  NULL,
    [SubmitterDept]      VARCHAR (200)  NULL,
    [IdeaStatus]         VARCHAR (300)  NULL,
    [SuccessMes]         VARCHAR (200)  NULL,
    [UOM]                VARCHAR (200)  NULL,
    [BaseLineVal]        FLOAT (53)     NULL,
    [TargetVal]          FLOAT (53)     NULL,
    [ActualVal]          FLOAT (53)     NULL,
    [ImportedOn]         DATETIME       NULL,
    [SubVerticalName]    VARCHAR (200)  NULL
);

