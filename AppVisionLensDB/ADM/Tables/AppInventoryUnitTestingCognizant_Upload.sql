CREATE TABLE [ADM].[AppInventoryUnitTestingCognizant_Upload] (
    [ID]                     BIGINT         IDENTITY (1, 1) NOT NULL,
    [ApplicationName]        NVARCHAR (500) NULL,
    [NFRCaptured]            NVARCHAR (10)  NULL,
    [IsUnitTestAutomated]    NVARCHAR (10)  NULL,
    [UnitTestFrameworkID]    NVARCHAR (500) NULL,
    [OtherUnitTestFramework] NVARCHAR (500) NULL,
    [TestingCoverage]        DECIMAL (5, 2) NULL,
    [IsRegressionTest]       NVARCHAR (10)  NULL,
    [RegressionTestCoverage] DECIMAL (5, 2) NULL,
    [IsCognizant]            BIT            NULL,
    [CustomerId]             NVARCHAR (100) NULL,
    [IsValid]                NVARCHAR (20)  NULL,
    [IsDeleted]              BIT            NULL,
    [CreatedBy]              NVARCHAR (100) NOT NULL,
    [CreatedDate]            DATETIME       NOT NULL,
    [ModifiedBy]             NVARCHAR (100) NULL,
    [ModifiedDate]           DATETIME       NULL
);

