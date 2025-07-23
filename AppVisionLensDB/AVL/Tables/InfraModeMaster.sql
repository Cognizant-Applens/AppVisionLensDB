CREATE TABLE [AVL].[InfraModeMaster] (
    [InfraModeId]   INT           IDENTITY (1, 1) NOT NULL,
    [InfraModeName] NVARCHAR (50) NULL,
    [IsDeleted]     BIT           NULL,
    [CreatedBy]     NVARCHAR (50) NULL,
    [CreatedDate]   DATETIME      NULL,
    [ModifiedBy]    NVARCHAR (50) NULL,
    [ModifiedDate]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([InfraModeId] ASC)
);

