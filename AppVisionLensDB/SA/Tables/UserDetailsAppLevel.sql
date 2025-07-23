CREATE TABLE [SA].[UserDetailsAppLevel] (
    [UserDetailsAppID]  INT           IDENTITY (1, 1) NOT NULL,
    [UserDetailsRoleID] INT           NOT NULL,
    [BusinessCluster]   TEXT          NULL,
    [AppType]           TEXT          NULL,
    [ApplicationName]   VARCHAR (100) NULL,
    [IsActive]          BIT           DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([UserDetailsAppID] ASC, [UserDetailsRoleID] ASC)
);

