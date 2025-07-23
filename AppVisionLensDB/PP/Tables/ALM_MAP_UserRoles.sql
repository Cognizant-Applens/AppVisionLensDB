CREATE TABLE [PP].[ALM_MAP_UserRoles] (
    [ID]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [EmployeeID]   NVARCHAR (50) NULL,
    [RoleID]       INT           NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

