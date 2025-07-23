CREATE TABLE [AVL].[RegexJobStatus] (
    [ID]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [RegexConfigID]      BIGINT         NOT NULL,
    [ConfigTypeID]       INT            NOT NULL,
    [EffectiveStartDate] DATETIME       NULL,
    [EffectiveEndDate]   DATETIME       NULL,
    [InitiatedBy]        NVARCHAR (50)  NOT NULL,
    [InitiatedOn]        DATETIME       NOT NULL,
    [ProcessStartDate]   DATETIME       NULL,
    [ProcessEndDate]     DATETIME       NULL,
    [JobMessage]         NVARCHAR (500) NOT NULL,
    [IsDeleted]          BIT            NOT NULL,
    [CreatedBy]          NVARCHAR (50)  NOT NULL,
    [CreatedDate]        DATETIME       NOT NULL,
    [ModifiedBy]         NVARCHAR (50)  NULL,
    [ModifiedDate]       DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_ProjectRegexConfiguration] FOREIGN KEY ([RegexConfigID]) REFERENCES [AVL].[PRJ_RegexConfiguration] ([RegexConfigID]),
    CONSTRAINT [FK_Regex_ConfigType] FOREIGN KEY ([ConfigTypeID]) REFERENCES [MAS].[Regex_Config] ([ID])
);

