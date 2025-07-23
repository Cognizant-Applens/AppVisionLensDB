CREATE TABLE [AVL].[PRJ_MAP_MultilingualLanguage] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [ProjectID]    BIGINT        NOT NULL,
    [LanguageID]   INT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    [Isdeleted]    BIT           NULL,
    FOREIGN KEY ([LanguageID]) REFERENCES [MAS].[MAS_LanguageMaster] ([LanguageID])
);

