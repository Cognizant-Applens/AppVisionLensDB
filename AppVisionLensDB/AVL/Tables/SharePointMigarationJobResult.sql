CREATE TABLE [AVL].[SharePointMigarationJobResult] (
    [ID]             INT            NOT NULL,
    [SharedPath]     VARCHAR (1500) NOT NULL,
    [SharedPathType] VARCHAR (100)  NOT NULL,
    [ProjectID]      INT            NULL,
    [EmployeeID]     INT            NULL,
    [Result]         VARCHAR (255)  NULL,
    [ErrorMessage]   VARCHAR (MAX)  NULL,
    [DateCreated]    DATETIME       DEFAULT (getdate()) NULL
);

