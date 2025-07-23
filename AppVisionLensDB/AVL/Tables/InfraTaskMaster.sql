CREATE TABLE [AVL].[InfraTaskMaster] (
    [InfraTaskID]   INT             IDENTITY (1, 1) NOT NULL,
    [InfraTaskName] NVARCHAR (1000) NOT NULL,
    [IsDeleted]     BIT             NULL,
    [CreatedBy]     NVARCHAR (50)   NULL,
    [CreatedDate]   DATETIME        NULL,
    [ModifiedBy]    NVARCHAR (50)   NULL,
    [ModifiedDate]  DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([InfraTaskID] ASC)
);

