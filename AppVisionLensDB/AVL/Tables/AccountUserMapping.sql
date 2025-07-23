CREATE TABLE [AVL].[AccountUserMapping] (
    [AccountUserMapId] INT          IDENTITY (1, 1) NOT NULL,
    [AccountId]        INT          NOT NULL,
    [UserId]           INT          NOT NULL,
    [CreatedBy]        VARCHAR (20) NULL,
    [CreatedOn]        DATETIME     NULL,
    [ModifiedBy]       VARCHAR (20) NULL,
    [ModifiedOn]       DATETIME     NULL,
    CONSTRAINT [PK_AVL.AccountUserMapping] PRIMARY KEY CLUSTERED ([AccountUserMapId] ASC)
);

