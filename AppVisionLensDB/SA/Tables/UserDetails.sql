CREATE TABLE [SA].[UserDetails] (
    [UserDetailsID] INT            IDENTITY (1, 1) NOT NULL,
    [UserId]        NVARCHAR (45)  DEFAULT (NULL) NULL,
    [UserName]      NVARCHAR (255) NULL,
    [EmailID]       NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([UserDetailsID] ASC)
);

