CREATE TABLE [AVL].[UserPreferenceLanguage] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [EmployeeID]   NVARCHAR (100) NOT NULL,
    [LanguageID]   INT            NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [ModifiedDate] DATETIME       NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [IsDeleted]    BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    FOREIGN KEY ([LanguageID]) REFERENCES [MAS].[MAS_LanguageMaster] ([LanguageID]),
    CONSTRAINT [U_EmployeeID] UNIQUE NONCLUSTERED ([EmployeeID] ASC)
);

