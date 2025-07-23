CREATE TABLE [MAS].[Modules] (
    [ModuleId]     INT           IDENTITY (1, 1) NOT NULL,
    [ModuleName]   VARCHAR (100) NULL,
    [Isdeleted]    BIT           DEFAULT ((0)) NULL,
    [CreatedBy]    VARCHAR (50)  NULL,
    [CreatedDate]  DATETIME      NULL,
    [ModifiedBy]   VARCHAR (50)  NULL,
    [ModifiedDate] DATETIME      NULL,
    [ModuleCode]   VARCHAR (25)  NULL,
    PRIMARY KEY CLUSTERED ([ModuleId] ASC)
);

