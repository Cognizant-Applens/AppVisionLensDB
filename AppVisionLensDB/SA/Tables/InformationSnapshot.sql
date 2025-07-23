CREATE TABLE [SA].[InformationSnapshot] (
    [InformationSnapshotId]    INT            IDENTITY (1, 1) NOT NULL,
    [InformationApplicationId] BIGINT         NOT NULL,
    [AnalyticsType]            NVARCHAR (100) NOT NULL,
    [InformationCreatedOn]     DATETIME       DEFAULT (NULL) NULL,
    [HighValue]                INT            DEFAULT (NULL) NULL,
    [MediumValue]              INT            DEFAULT (NULL) NULL,
    [LowValue]                 INT            DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([InformationSnapshotId] ASC)
);

