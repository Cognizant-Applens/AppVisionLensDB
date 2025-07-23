CREATE TABLE [SA].[RankMaster] (
    [ParameterId]      BIGINT NOT NULL,
    [MaximumAdherence] INT    DEFAULT (NULL) NULL,
    [MinimumAdherence] INT    DEFAULT (NULL) NULL,
    [RankNumber]       INT    DEFAULT (NULL) NULL,
    [ApplicationId]    BIGINT NOT NULL,
    [RankId]           INT    IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([RankId] ASC),
    CONSTRAINT [FK_RankMaster_ParameterMaster] FOREIGN KEY ([ParameterId]) REFERENCES [SA].[ParameterMaster] ([ParameterId])
);

