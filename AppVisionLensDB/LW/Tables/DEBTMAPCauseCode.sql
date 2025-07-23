CREATE TABLE [LW].[DEBTMAPCauseCode] (
    [CauseCodeID]  BIGINT         NOT NULL,
    [CauseCode]    NVARCHAR (500) NULL,
    [IsDeleted]    BIT            NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [ModifiedDate] DATETIME       NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    CONSTRAINT [PK_DEBTMAPCauseCode] PRIMARY KEY CLUSTERED ([CauseCodeID] ASC)
);

