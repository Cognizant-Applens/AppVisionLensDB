CREATE TABLE [AVL].[MAS_Phase] (
    [PhaseId]    INT           IDENTITY (1, 1) NOT NULL,
    [Name]       NVARCHAR (50) NOT NULL,
    [IsDeleted]  BIT           NOT NULL,
    [CreatedBy]  NVARCHAR (50) NOT NULL,
    [CreatedOn]  DATETIME      NOT NULL,
    [ModifiedBy] NVARCHAR (50) NULL,
    [ModifiedOn] DATETIME      NULL,
    CONSTRAINT [PK_Phase] PRIMARY KEY CLUSTERED ([PhaseId] ASC)
);

