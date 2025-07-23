CREATE TABLE [AVL].[BenchMarkAnalysisTrack] (
    [ID]            BIGINT        IDENTITY (1, 1) NOT NULL,
    [AnalysisID]    BIGINT        NOT NULL,
    [StartDate]     DATETIME      NULL,
    [EndDate]       DATETIME      NULL,
    [EffectiveDate] DATETIME      NULL,
    [IsDeleted]     BIT           NOT NULL,
    [CreatedBy]     NVARCHAR (50) NOT NULL,
    [CreatedDate]   DATETIME      NOT NULL,
    [ModifiedBy]    NVARCHAR (50) NULL,
    [ModifiedDate]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

