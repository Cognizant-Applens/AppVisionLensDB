CREATE TABLE [MAS].[ApplensModule] (
    [ID]                 INT            IDENTITY (1, 1) NOT NULL,
    [ModuleName]         NVARCHAR (50)  NOT NULL,
    [Description]        NVARCHAR (500) NULL,
    [ProjectScopeConfig] NVARCHAR (500) NULL,
    [ALMToolConfig]      NVARCHAR (500) NULL,
    [ShowInUI]           BIT            NOT NULL,
    [IsDeleted]          BIT            NOT NULL,
    [CreatedBy]          NVARCHAR (50)  NOT NULL,
    [CreatedDate]        DATETIME       NOT NULL,
    [ModifiedBy]         NVARCHAR (50)  NOT NULL,
    [ModifiedDate]       DATETIME       NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

