﻿CREATE TABLE [PP].[Transition_AppInventroyAttributes] (
    [ID]                          INT           IDENTITY (1, 1) NOT NULL,
    [ApplicationId]               BIGINT        NOT NULL,
    [CustomerId]                  BIGINT        NOT NULL,
    [EsaProjectId]                BIGINT        NOT NULL,
    [KTNeeded]                    INT           NOT NULL,
    [LanguageRequirements]        VARCHAR (50)  NOT NULL,
    [WaveorCluster]               VARCHAR (100) NULL,
    [ApplicationOwnerIT]          VARCHAR (50)  NULL,
    [CRType]                      INT           NOT NULL,
    [HardwareSoftwareRequirement] VARCHAR (50)  NULL,
    [BusinessFunction]            INT           NULL,
    [OperationallyCritical]       INT           NULL,
    [SecurityCritical]            INT           NULL,
    [HighTouch]                   INT           NULL,
    [PriceperMonth]               VARCHAR (50)  NULL,
    [SLALevel]                    INT           NULL,
    [VendorTypeName]              VARCHAR (50)  NULL,
    [VendorName]                  VARCHAR (50)  NULL,
    [OtherVendorTypeName]         VARCHAR (50)  NULL,
    [isDeleted]                   BIT           NOT NULL,
    [CreatedBy]                   NVARCHAR (50) NOT NULL,
    [CreatedDate]                 DATETIME      NOT NULL,
    [ModifiedBy]                  NVARCHAR (50) NULL,
    [ModifiedDate]                DATETIME      NULL,
    CONSTRAINT [PK_PP.Transition_AppInventroyAttributes] PRIMARY KEY CLUSTERED ([ID] ASC, [ApplicationId] ASC, [CustomerId] ASC)
);

