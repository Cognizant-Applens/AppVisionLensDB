CREATE TABLE [ML].[TRN_StopWords] (
    [StopWordsId]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectId]     BIGINT        NOT NULL,
    [ApplicationId] BIGINT        NULL,
    [TowerId]       BIGINT        NULL,
    [StopWordKey]   NVARCHAR (10) NOT NULL,
    [StopWords]     NVARCHAR (25) NOT NULL,
    [Frequency]     INT           NOT NULL,
    [IsActive]      BIT           NOT NULL,
    [IsAppInfra]    SMALLINT      NOT NULL,
    [IsDeleted]     BIT           NOT NULL,
    [CreatedBy]     NVARCHAR (50) NOT NULL,
    [CreatedDate]   DATETIME      CONSTRAINT [DF_TRN_StopWords_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]    NVARCHAR (50) NULL,
    [ModifiedDate]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([StopWordsId] ASC)
);

