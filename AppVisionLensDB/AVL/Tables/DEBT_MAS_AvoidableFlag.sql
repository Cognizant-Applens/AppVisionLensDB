CREATE TABLE [AVL].[DEBT_MAS_AvoidableFlag] (
    [AvoidableFlagID]   INT           IDENTITY (1, 1) NOT NULL,
    [AvoidableFlagName] NVARCHAR (50) NOT NULL,
    [IsDeleted]         BIT           NOT NULL,
    [CreatedBy]         NVARCHAR (50) NOT NULL,
    [CreatedDate]       DATETIME      NOT NULL,
    [ModifiedBy]        NVARCHAR (50) NULL,
    [ModifiedDate]      DATETIME      NULL,
    CONSTRAINT [PK__DEBT_MAS__C10109BDEE71F507] PRIMARY KEY CLUSTERED ([AvoidableFlagID] ASC)
);

