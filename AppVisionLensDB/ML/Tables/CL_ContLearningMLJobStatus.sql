CREATE TABLE [ML].[CL_ContLearningMLJobStatus] (
    [MLJobID]        BIGINT          IDENTITY (1, 1) NOT NULL,
    [ProjectID]      BIGINT          NOT NULL,
    [ContLearningID] BIGINT          NOT NULL,
    [JobIDFromML]    NVARCHAR (150)  NULL,
    [InputFileName]  NVARCHAR (1000) NULL,
    [OutputFileName] NVARCHAR (1000) NULL,
    [DataPath]       NVARCHAR (2000) NULL,
    [InitiatedBy]    NVARCHAR (50)   NULL,
    [JobMessage]     NVARCHAR (2000) NULL,
    [CreatedBy]      NVARCHAR (50)   NOT NULL,
    [CreatedDate]    DATETIME        NOT NULL,
    [ModifiedBy]     NVARCHAR (50)   NULL,
    [ModifiedDate]   DATETIME        NULL,
    [CLJobStatus]    INT             NULL,
    [IsDeleted]      BIT             NOT NULL,
    [PatternSharing] NVARCHAR (10)   DEFAULT ('Yes') NOT NULL,
    [OutputParam]    TINYINT         NULL,
    PRIMARY KEY CLUSTERED ([MLJobID] ASC),
    FOREIGN KEY ([ContLearningID]) REFERENCES [ML].[CL_PRJ_ContLearningState] ([ContLearningID])
);

