CREATE TABLE [AVL].[InfraTemplateMaster] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [AttributeName] NVARCHAR (255) NOT NULL,
    [IsDeleted]     BIT            NULL,
    [CreatedBy]     NVARCHAR (50)  NULL,
    [CreatedDate]   DATETIME       NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    [ModifiedDate]  DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

