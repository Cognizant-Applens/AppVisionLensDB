CREATE TABLE [AVL].[ML_ILCountDetails] (
    [ID]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [InitialLearningID] BIGINT         NULL,
    [ProjectID]         BIGINT         NULL,
    [TASamplingCount]   BIGINT         NULL,
    [TCSamplingCount]   BIGINT         NULL,
    [SamplingCount]     BIGINT         NULL,
    [TABeforeML]        BIGINT         NULL,
    [TCBeforeML]        BIGINT         NULL,
    [PatternCount]      BIGINT         NULL,
    [TAAfterML]         BIGINT         NULL,
    [TCAfterML]         BIGINT         NULL,
    [ApprovedCount]     BIGINT         NULL,
    [MuteCount]         BIGINT         NULL,
    [Isdeleted]         BIT            NULL,
    [CreatedBy]         NVARCHAR (MAX) NULL,
    [CreatedDate]       DATE           NULL,
    [ModifiedBy]        NVARCHAR (MAX) NULL,
    [ModifiedDate]      DATE           NULL
);

