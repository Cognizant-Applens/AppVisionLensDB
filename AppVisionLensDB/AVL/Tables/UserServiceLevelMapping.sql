CREATE TABLE [AVL].[UserServiceLevelMapping] (
    [ID]             INT             IDENTITY (1, 1) NOT NULL,
    [ServiceLevelID] NVARCHAR (MAX)  NULL,
    [CustomerID]     BIGINT          NULL,
    [EmployeeID]     NVARCHAR (1000) NULL,
    [CreatedBy]      NVARCHAR (50)   NULL,
    [CreatedDate]    DATETIME        NULL,
    [ProjectID]      NCHAR (10)      NULL,
    CONSTRAINT [PK__User_Use__3214EC2750C37BE9] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20190716-111048]
    ON [AVL].[UserServiceLevelMapping]([CustomerID] ASC, [EmployeeID] ASC, [ProjectID] ASC)
    INCLUDE([ID], [ServiceLevelID]);


GO
CREATE NONCLUSTERED INDEX [NC_US_Pro_Emp]
    ON [AVL].[UserServiceLevelMapping]([EmployeeID] ASC, [ProjectID] ASC)
    INCLUDE([ServiceLevelID]);

