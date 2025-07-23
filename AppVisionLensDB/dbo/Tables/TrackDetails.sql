CREATE TABLE [dbo].[TrackDetails] (
    [Id]                BIGINT        IDENTITY (1, 1) NOT NULL,
    [JobId]             BIGINT        NOT NULL,
    [JobStartTime]      DATETIME      NULL,
    [JobEndTime]        DATETIME      NULL,
    [TransactionId]     BIGINT        NOT NULL,
    [JobStatus]         NVARCHAR (50) NOT NULL,
    [IsMailerCompleted] BIT           CONSTRAINT [DF_ML.TrackDetails_IsMailerCompleted] DEFAULT ((0)) NULL,
    [IsDeleted]         BIT           CONSTRAINT [DF_ML.TrackDetails_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]         NVARCHAR (50) NOT NULL,
    [CreatedDate]       DATETIME      NOT NULL,
    [ModifiedBy]        NVARCHAR (50) NULL,
    [ModifiedDate]      DATETIME      NULL,
    CONSTRAINT [PK_ML.TrackDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);

