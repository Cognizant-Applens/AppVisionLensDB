CREATE TABLE [SA].[IncidentSnapshot] (
    [IncidentSnapshotId]            INT            IDENTITY (1, 1) NOT NULL,
    [IncidentSnapshotApplicationId] BIGINT         NOT NULL,
    [SnapTimestamp]                 DATETIME       DEFAULT (NULL) NULL,
    [IncidentSnapshotCreatedCount]  INT            DEFAULT (NULL) NULL,
    [IncidentSnapshotOpenCount]     INT            DEFAULT (NULL) NULL,
    [IncidentSnapshotWipCount]      INT            DEFAULT (NULL) NULL,
    [IncidentSnapshotTicketType]    NVARCHAR (100) DEFAULT (NULL) NULL,
    [IncidentSnapshotClosedCount]   INT            DEFAULT (NULL) NULL,
    [P1Count]                       INT            DEFAULT (NULL) NULL,
    [P2Count]                       INT            DEFAULT (NULL) NULL,
    [P3Count]                       INT            DEFAULT (NULL) NULL,
    [P4Count]                       INT            DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([IncidentSnapshotId] ASC)
);

