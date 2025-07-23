CREATE TABLE [SA].[CriticalityMaster] (
    [CriticalityId]           INT            IDENTITY (1, 1) NOT NULL,
    [CriticalityName]         NVARCHAR (500) DEFAULT (NULL) NULL,
    [CriticalityIsDeleted]    NVARCHAR (10)  DEFAULT (NULL) NULL,
    [CriticalityCreatedBy]    NVARCHAR (10)  DEFAULT (NULL) NULL,
    [CriticalityCreatedOn]    DATETIME       DEFAULT (NULL) NULL,
    [CriticalityModifiedBy]   NVARCHAR (10)  DEFAULT (NULL) NULL,
    [CriticalityModifiedDate] DATETIME       DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([CriticalityId] ASC)
);

