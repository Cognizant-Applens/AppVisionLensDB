CREATE TABLE [MAS].[JobMaster] (
    [JobID]       BIGINT        IDENTITY (1, 1) NOT NULL,
    [JobName]     VARCHAR (100) NOT NULL,
    [IsDeleted]   BIT           NOT NULL,
    [CreatedBy]   NVARCHAR (50) NOT NULL,
    [CreatedDate] DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([JobID] ASC)
);

