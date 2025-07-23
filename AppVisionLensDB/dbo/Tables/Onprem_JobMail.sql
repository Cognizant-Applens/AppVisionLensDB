CREATE TABLE [dbo].[Onprem_JobMail] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [EmployeeID]    NVARCHAR (50)  NOT NULL,
    [EmployeeName]  NVARCHAR (100) NOT NULL,
    [EmployeeEmail] NVARCHAR (100) NOT NULL,
    [IsActive]      BIT            NOT NULL,
    [CreatedDate]   DATETIME       NULL,
    [CreatedBy]     NVARCHAR (50)  NULL,
    [ModifiedDate]  DATETIME       NULL,
    [ModifiedBy]    NVARCHAR (50)  NULL,
    [IsCC]          VARCHAR (1)    NOT NULL,
    CONSTRAINT [PK_Onprem_JobMail] PRIMARY KEY CLUSTERED ([ID] ASC)
);

