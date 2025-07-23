CREATE TABLE [MAS].[JobWiseMailDetails] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [EmployeeName]  NVARCHAR (100) NOT NULL,
    [EmployeeEmail] NVARCHAR (100) NOT NULL,
    [JobId]         INT            NOT NULL,
    [IsDeleted]     BIT            NOT NULL,
    [CreatedDate]   DATETIME       NULL,
    [CreatedBy]     NVARCHAR (50)  NULL,
    [ModifiedDate]  DATETIME       NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

