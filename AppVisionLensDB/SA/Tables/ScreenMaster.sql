CREATE TABLE [SA].[ScreenMaster] (
    [ScreenMasterId] INT            NOT NULL,
    [ScreenName]     NVARCHAR (255) DEFAULT (NULL) NULL,
    [IsActive]       BIT            DEFAULT (NULL) NULL,
    [CreatedOn]      DATETIME       DEFAULT (NULL) NULL,
    [CreatedBy]      NVARCHAR (255) DEFAULT (NULL) NULL,
    [ModifiedOn]     DATETIME       DEFAULT (NULL) NULL,
    [ModifiedBy]     NVARCHAR (255) DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([ScreenMasterId] ASC)
);

