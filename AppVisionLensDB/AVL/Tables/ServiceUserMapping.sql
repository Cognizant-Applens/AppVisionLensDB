CREATE TABLE [AVL].[ServiceUserMapping] (
    [ServiceUserId] INT          IDENTITY (1, 1) NOT NULL,
    [ServiceId]     INT          NULL,
    [UserId]        INT          NULL,
    [CreatedBy]     VARCHAR (20) NULL,
    [CreatedOn]     DATETIME     NULL,
    [ModifiedBy]    VARCHAR (20) NULL,
    [ModifiedOn]    DATETIME     NULL,
    CONSTRAINT [PK_ServiceUserMapping] PRIMARY KEY CLUSTERED ([ServiceUserId] ASC)
);

