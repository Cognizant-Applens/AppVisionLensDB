CREATE TABLE [ML].[CLandManualClassificationReviewDetails] (
    [ReviewCLId]      BIGINT        IDENTITY (1, 1) NOT NULL,
    [MLTransactionId] BIGINT        NOT NULL,
    [ProjectID]       BIGINT        NOT NULL,
    [FromDate]        DATETIME      NOT NULL,
    [ToDate]          DATETIME      NOT NULL,
    [IsManual]        BIT           NOT NULL,
    [IsDeleted]       BIT           CONSTRAINT [DF__CLandManu__IsDel__746CC2BD] DEFAULT ((0)) NOT NULL,
    [CreatedBy]       NVARCHAR (50) NOT NULL,
    [CreatedDate]     DATETIME      CONSTRAINT [DF_CLandManualClassificationReviewDetails_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]      NVARCHAR (50) NULL,
    [ModifiedDate]    DATETIME      NULL,
    [FileName]        VARCHAR (100) NULL
);

