﻿CREATE TYPE [dbo].[TVP_AppInventoryApplicationDetailsUpload_Cognizant] AS TABLE (
    [ApplicationName]          NVARCHAR (100) NULL,
    [ApplicationCode]          NVARCHAR (50)  NULL,
    [ApplicationShortName]     NVARCHAR (8)   NULL,
    [BusinessClusterName]      VARCHAR (MAX)  NULL,
    [CodeOwnerShip]            VARCHAR (MAX)  NULL,
    [BusinessCriticalityName]  VARCHAR (MAX)  NULL,
    [PrimaryTechnologyName]    VARCHAR (MAX)  NULL,
    [ProductMarketName]        VARCHAR (MAX)  NULL,
    [ApplicationDescription]   NVARCHAR (200) NULL,
    [ApplicationCommisionDate] DATETIME       NULL,
    [RegulatoryCompliantName]  VARCHAR (MAX)  NULL,
    [DebtcontrolScopeName]     VARCHAR (MAX)  NULL,
    [UserBase]                 NVARCHAR (50)  NULL,
    [SupportWindowName]        VARCHAR (MAX)  NULL,
    [Incallwdgreen]            NVARCHAR (50)  NULL,
    [Infraallwdgreen]          NVARCHAR (50)  NULL,
    [Incallwdamber]            NVARCHAR (50)  NULL,
    [Infraallwdamber]          NVARCHAR (50)  NULL,
    [Infoallwdamber]           NVARCHAR (50)  NULL,
    [Infoallwdgreen]           NVARCHAR (50)  NULL,
    [SupportCategoryName]      VARCHAR (MAX)  NULL,
    [OperatingSystem]          NVARCHAR (100) NULL,
    [ServerConfiguration]      NVARCHAR (100) NULL,
    [ServerOwner]              NVARCHAR (100) NULL,
    [LicenseDetails]           NVARCHAR (100) NULL,
    [DatabaseVersion]          NVARCHAR (100) NULL,
    [HostedEnvironmentName]    VARCHAR (MAX)  NULL,
    [CloudServiceProvider]     VARCHAR (MAX)  NULL,
    [CloudModel]               VARCHAR (20)   NULL,
    [OtherTechnology]          NVARCHAR (150) NULL,
    [OtherServiceProvider]     NVARCHAR (150) NULL,
    [OtherWindow]              NVARCHAR (50)  NULL,
    [ApplicationScope]         NVARCHAR (300) NULL,
    [IsRevenue]                NVARCHAR (10)  NULL,
    [GeographiesSupported]     NVARCHAR (500) NULL,
    [FunctionalKnowledge]      NVARCHAR (150) NULL,
    [ExecutionMethod]          NVARCHAR (500) NULL,
    [OtherExecutionMethod]     NVARCHAR (250) NULL,
    [SourceCodeAvailability]   NVARCHAR (150) NULL,
    [RegulatoryBody]           NVARCHAR (150) NULL,
    [OtherRegulatoryBody]      NVARCHAR (250) NULL,
    [IsAppAvailable]           NVARCHAR (10)  NULL,
    [AvailabilityPercent]      DECIMAL (5, 2) NULL,
    [NFRCaptured]              NVARCHAR (10)  NULL,
    [IsUnitTestAutomated]      NVARCHAR (10)  NULL,
    [UnitTestFrameworkID]      NVARCHAR (500) NULL,
    [OtherUnitTestFramework]   NVARCHAR (500) NULL,
    [TestingCoverage]          DECIMAL (5, 2) NULL,
    [IsRegressionTest]         NVARCHAR (10)  NULL,
    [RegressionTestCoverage]   DECIMAL (5, 2) NULL,
    [Active]                   VARCHAR (5)    NULL,
    [CustomerId]               VARCHAR (MAX)  NULL,
    [IsValid]                  VARCHAR (MAX)  NULL);

