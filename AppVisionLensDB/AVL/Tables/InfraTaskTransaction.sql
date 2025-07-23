CREATE TABLE [AVL].[InfraTaskTransaction] (
    [InfraTransactionTaskID] INT             IDENTITY (1, 1) NOT NULL,
    [CustomerID]             BIGINT          NOT NULL,
    [InfraTaskName]          NVARCHAR (1000) NOT NULL,
    [IsDeleted]              BIT             NULL,
    [CreatedBy]              NVARCHAR (50)   NULL,
    [CreatedDate]            DATETIME        NULL,
    [ModifiedBy]             NVARCHAR (50)   NULL,
    [ModifiedDate]           DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([InfraTransactionTaskID] ASC)
);

