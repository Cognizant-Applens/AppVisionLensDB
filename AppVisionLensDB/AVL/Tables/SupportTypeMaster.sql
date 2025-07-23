CREATE TABLE [AVL].[SupportTypeMaster] (
    [SupportTypeId]   INT           IDENTITY (1, 1) NOT NULL,
    [SupportTypeName] NVARCHAR (50) NULL,
    [IsDeleted]       BIT           NULL,
    [CreatedBy]       NVARCHAR (50) NULL,
    [CreatedDate]     DATETIME      NULL,
    [ModifiedBy]      NVARCHAR (50) NULL,
    [ModifiedDate]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([SupportTypeId] ASC)
);

