CREATE TABLE [ESA].[ProjectDepartment] (
    [ESAProjectID]    VARCHAR (50)  NOT NULL,
    [DepartmentName]  VARCHAR (500) NOT NULL,
    [IsDeleted]       BIT           NOT NULL,
    [CreatedBy]       NVARCHAR (50) NOT NULL,
    [CreatedDateTime] DATETIME      NOT NULL
);

