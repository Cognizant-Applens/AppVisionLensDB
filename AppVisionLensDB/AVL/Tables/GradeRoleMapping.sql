CREATE TABLE [AVL].[GradeRoleMapping] (
    [GradeId]    INT            IDENTITY (1, 1) NOT NULL,
    [Grade]      NVARCHAR (100) NOT NULL,
    [IsActive]   BIT            NOT NULL,
    [CreatedBy]  NVARCHAR (50)  NOT NULL,
    [CreatedOn]  DATETIME       NOT NULL,
    [ModifiedBy] NVARCHAR (50)  NULL,
    [ModofiedOn] DATETIME       NULL,
    CONSTRAINT [PK_GradeRoleMapping] PRIMARY KEY CLUSTERED ([GradeId] ASC),
    UNIQUE NONCLUSTERED ([Grade] ASC)
);

