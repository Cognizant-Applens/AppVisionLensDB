CREATE TABLE [AVL].[ML_ILCountDetailsInfra] (
    [Id]                BIGINT        IDENTITY (1, 1) NOT NULL,
    [InitialLearningID] BIGINT        NULL,
    [ProjectID]         BIGINT        NOT NULL,
    [TASamplingCount]   INT           NULL,
    [TCSamplingCount]   INT           NULL,
    [SamplingCount]     INT           NULL,
    [TABeforeML]        INT           NULL,
    [TCBeforeML]        INT           NULL,
    [PatternCount]      INT           NULL,
    [TAAfterML]         INT           NULL,
    [TCAfterML]         INT           NULL,
    [ApprovedCount]     INT           NULL,
    [MuteCount]         INT           NULL,
    [IsDeleted]         BIT           NULL,
    [CreatedBy]         NVARCHAR (50) NULL,
    [CreatedDate]       DATETIME      NULL,
    [ModifiedBy]        NVARCHAR (50) NULL,
    [ModifiedDate]      DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

