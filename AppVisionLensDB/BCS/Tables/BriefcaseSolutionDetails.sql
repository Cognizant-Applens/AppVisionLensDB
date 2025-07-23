CREATE TABLE [BCS].[BriefcaseSolutionDetails] (
    [RecordId]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [UserId]               NVARCHAR (50) NOT NULL,
    [ESAProjectID]         INT           NULL,
    [SolutionId]           INT           NULL,
    [LicenseKey]           NVARCHAR (50) NOT NULL,
    [LicenseKeyExpiryDate] DATETIME      NOT NULL,
    [IsDeleted]            BIT           DEFAULT ((0)) NOT NULL,
    [CreatedBy]            NVARCHAR (50) DEFAULT ('SYSTEM') NOT NULL,
    [CreatedDate]          DATETIME      DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]           NVARCHAR (50) DEFAULT ('SYSTEM') NULL,
    [ModifiedDate]         DATETIME      DEFAULT (getdate()) NULL,
    [Download]             SMALLINT      NULL,
    PRIMARY KEY CLUSTERED ([RecordId] ASC)
);

