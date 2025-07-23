CREATE TABLE [PP].[ApplicationQualityAttributes] (
    [AppQualityID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [ApplicationID]          BIGINT         NOT NULL,
    [NFRCaptured]            VARCHAR (10)   NULL,
    [IsUnitTestAutomated]    BIT            NULL,
    [TestingCoverage]        DECIMAL (5, 2) NULL,
    [IsRegressionTest]       BIT            NULL,
    [RegressionTestCoverage] DECIMAL (5, 2) NULL,
    [IsDeleted]              BIT            NOT NULL,
    [CreatedBy]              VARCHAR (50)   NOT NULL,
    [CreatedOn]              DATETIME       NOT NULL,
    [ModifiedBy]             VARCHAR (50)   NULL,
    [ModifiedOn]             DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([AppQualityID] ASC),
    FOREIGN KEY ([ApplicationID]) REFERENCES [AVL].[APP_MAS_ApplicationDetails] ([ApplicationID])
);

