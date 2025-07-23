CREATE TABLE [SA].[RoleMaster] (
    [ModuleId]       NVARCHAR (100) NOT NULL,
    [ModuleName]     NVARCHAR (100) NOT NULL,
    [ScreenName]     NVARCHAR (100) NOT NULL,
    [RoleType]       NVARCHAR (100) NOT NULL,
    [ApplicationId]  BIGINT         NOT NULL,
    [LineOfBuisness] NVARCHAR (100) DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([ModuleId] ASC)
);

