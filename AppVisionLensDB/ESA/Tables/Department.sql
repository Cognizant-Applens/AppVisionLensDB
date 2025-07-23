CREATE TABLE [ESA].[Department] (
    [DepartmentID]     INT           IDENTITY (1, 1) NOT NULL,
    [DepartmentCode]   VARCHAR (255) NULL,
    [DepartmentName]   VARCHAR (500) NOT NULL,
    [IsDeleted]        BIT           NOT NULL,
    [CreatedBy]        NVARCHAR (50) NOT NULL,
    [CreatedDateTime]  DATETIME      NOT NULL,
    [ModifiedBy]       NVARCHAR (50) NULL,
    [ModifiedDateTime] DATETIME      NULL,
    CONSTRAINT [PK_ESA.Department] PRIMARY KEY CLUSTERED ([DepartmentID] ASC)
);

