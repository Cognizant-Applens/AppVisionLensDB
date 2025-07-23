CREATE TABLE [AC].[AssociateLensMailerConfig] (
    [Id]             INT           IDENTITY (1, 1) NOT NULL,
    [JobType]        NVARCHAR (50) NOT NULL,
    [IsConfigured]   BIT           DEFAULT ((0)) NOT NULL,
    [SpecificPeriod] SMALLINT      NULL,
    [SpecificYear]   INT           NULL,
    [IsDeleted]      BIT           DEFAULT ((0)) NOT NULL,
    [CreatedBy]      NVARCHAR (50) NOT NULL,
    [CreatedDate]    DATETIME      NOT NULL,
    [ModifiedBy]     NVARCHAR (50) NULL,
    [ModifiedDate]   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

