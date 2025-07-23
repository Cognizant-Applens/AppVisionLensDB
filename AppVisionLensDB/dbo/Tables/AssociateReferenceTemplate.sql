CREATE TABLE [dbo].[AssociateReferenceTemplate] (
    [AssociateRefID] INT            IDENTITY (1, 1) NOT NULL,
    [CategoryName]   NVARCHAR (50)  NULL,
    [AwardName]      NVARCHAR (50)  NULL,
    [EmployeeID]     NVARCHAR (50)  NULL,
    [ESAProjectID]   NVARCHAR (50)  NULL,
    [ReferenceId]    NVARCHAR (200) NULL,
    [Remarks]        NVARCHAR (500) NULL,
    [IsDeleted]      BIT            DEFAULT ((0)) NOT NULL,
    [CreatedDate]    DATETIME       DEFAULT (getdate()) NOT NULL,
    [ModifiedDate]   DATETIME       NULL,
    [CreatedBy]      NVARCHAR (50)  DEFAULT ('SYSTEM') NOT NULL,
    [ModifiedBy]     NVARCHAR (50)  NULL
);

