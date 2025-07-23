CREATE TABLE [AVL].[TK_MAS_ReasonForResidual] (
    [ReasonResidualID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [ReasonResidualName] NVARCHAR (50) NOT NULL,
    [IsDeleted]          BIT           NOT NULL,
    [CreatedBy]          NVARCHAR (50) NOT NULL,
    [CreatedDate]        DATETIME      NOT NULL,
    [ModifiedBy]         NVARCHAR (50) NULL,
    [ModifiedDate]       DATETIME      NULL,
    CONSTRAINT [PK_TK_MAS_ReasonForResidual] PRIMARY KEY CLUSTERED ([ReasonResidualID] ASC)
);

