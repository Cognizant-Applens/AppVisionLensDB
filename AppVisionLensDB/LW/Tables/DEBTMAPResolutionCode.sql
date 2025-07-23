CREATE TABLE [LW].[DEBTMAPResolutionCode] (
    [ResolutionCodeID] BIGINT         NOT NULL,
    [ResolutionCode]   NVARCHAR (500) NULL,
    [IsDeleted]        BIT            NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [CreatedBy]        NVARCHAR (50)  NOT NULL,
    [ModifiedDate]     DATETIME       NULL,
    [ModifiedBy]       NVARCHAR (50)  NULL,
    CONSTRAINT [PK_DEBT_MAP_ResolutionCode] PRIMARY KEY CLUSTERED ([ResolutionCodeID] ASC)
);

