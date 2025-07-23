CREATE TABLE [ADM].[ALM_TRN_Sprint_ReleaseMapping] (
    [SprintReleaseMappingId]    SMALLINT        IDENTITY (1, 1) NOT NULL,
    [CommittedUserStories]      SMALLINT        NULL,
    [CommittedEstimationPoints] DECIMAL (18, 2) NULL,
    [CommittedPlannedEffort]    DECIMAL (18, 2) NULL,
    [CommittedActualEffort]     DECIMAL (18, 2) NULL,
    [CompletedUserStories]      SMALLINT        NULL,
    [CompletedEstimationPoints] DECIMAL (18, 2) NULL,
    [CompletedPlannedEffort]    DECIMAL (18, 2) NULL,
    [CompletedActualEffort]     DECIMAL (18, 2) NULL,
    [AcceptedUserStories]       SMALLINT        NULL,
    [AcceptedEstimationPoints]  DECIMAL (18, 2) NULL,
    [AcceptedPlannedEffort]     DECIMAL (18, 2) NULL,
    [AcceptedActualEffort]      DECIMAL (18, 2) NULL,
    [SprintDetailsId]           BIGINT          NOT NULL,
    [IsDeleted]                 BIT             NOT NULL,
    [CreatedBy]                 NVARCHAR (50)   NOT NULL,
    [CreatedDate]               DATETIME        NOT NULL,
    [ModifiedBy]                NVARCHAR (50)   NULL,
    [ModifiedDate]              DATETIME        NULL,
    CONSTRAINT [PK_ALM_TRN_Sprint_ReleaseMapping] PRIMARY KEY CLUSTERED ([SprintReleaseMappingId] ASC),
    CONSTRAINT [FK_ALM_TRN_Sprint_DetailsId] FOREIGN KEY ([SprintDetailsId]) REFERENCES [ADM].[ALM_TRN_Sprint_Details] ([SprintDetailsId])
);

