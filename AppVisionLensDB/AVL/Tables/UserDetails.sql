CREATE TABLE [AVL].[UserDetails] (
    [UserDetailsID] INT            IDENTITY (1, 1) NOT NULL,
    [UserId]        NVARCHAR (45)  NOT NULL,
    [UserName]      NVARCHAR (70)  NOT NULL,
    [EmailID]       NVARCHAR (200) NOT NULL,
    PRIMARY KEY CLUSTERED ([UserDetailsID] ASC)
);

