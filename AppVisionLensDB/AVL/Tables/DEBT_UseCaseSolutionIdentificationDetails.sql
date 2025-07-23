CREATE TABLE [AVL].[DEBT_UseCaseSolutionIdentificationDetails] (
    [ID]                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [UseCaseID]            NVARCHAR (MAX) NULL,
    [HealingTicketID]      NVARCHAR (100) NOT NULL,
    [UseCaseSolutionMapId] BIGINT         NOT NULL,
    [IsMappedSolution]     BIT            NULL,
    [IsDeleted]            BIT            NULL,
    [CreatedBy]            VARCHAR (50)   NULL,
    [CreatedOn]            DATETIME       NULL,
    [ModifiedBy]           VARCHAR (50)   NULL,
    [ModifiedOn]           DATETIME       NULL,
    [ProjectID]            BIGINT         NULL,
    CONSTRAINT [PK__DEBT_MAP__UseCaseSolution] PRIMARY KEY CLUSTERED ([ID] ASC)
);

