CREATE TABLE [PP].[MAP_UnitTestingFramework] (
    [ID]                     BIGINT         IDENTITY (1, 1) NOT NULL,
    [ApplicationID]          BIGINT         NOT NULL,
    [UnitTestFrameworkID]    INT            NOT NULL,
    [OtherUnitTestFramework] NVARCHAR (150) NULL,
    [IsDeleted]              BIT            NOT NULL,
    [CreatedBy]              VARCHAR (50)   NOT NULL,
    [CreatedOn]              DATETIME       NOT NULL,
    [ModifiedBy]             VARCHAR (50)   NULL,
    [ModifiedOn]             DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    FOREIGN KEY ([ApplicationID]) REFERENCES [AVL].[APP_MAS_ApplicationDetails] ([ApplicationID]),
    FOREIGN KEY ([UnitTestFrameworkID]) REFERENCES [PP].[MAS_UnitTestingFramework] ([UnitTestFrameworkID])
);

