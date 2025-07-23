CREATE TABLE [AVL].[DEBT_MAS_ResolutionMethod] (
    [ResolutionMethodID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [ResolutionMethodName] NVARCHAR (50) NOT NULL,
    [IsDeleted]            BIT           NOT NULL,
    [CreatedBy]            NVARCHAR (50) NOT NULL,
    [CreatedDate]          DATETIME      CONSTRAINT [DF_DEPT_MAS_ResolutionMethod_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]           NVARCHAR (50) NULL,
    [ModifiedDate]         DATETIME      NULL,
    CONSTRAINT [PK_DEPT_MAS_ResolutionMethod] PRIMARY KEY CLUSTERED ([ResolutionMethodID] ASC)
);

