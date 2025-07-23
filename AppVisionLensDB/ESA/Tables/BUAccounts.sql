CREATE TABLE [ESA].[BUAccounts] (
    [AccountID]        INT           NOT NULL,
    [BUID]             SMALLINT      NOT NULL,
    [AccountName]      VARCHAR (100) NOT NULL,
    [IsActive]         BIT           CONSTRAINT [DF_BUAccounts_IsActive] DEFAULT ((1)) NOT NULL,
    [LastModifiedDate] DATETIME      CONSTRAINT [DF_BUAccounts_LastModifiedDate] DEFAULT (getdate()) NOT NULL,
    [IsCustomAccount]  BIT           DEFAULT ((0)) NULL
);

