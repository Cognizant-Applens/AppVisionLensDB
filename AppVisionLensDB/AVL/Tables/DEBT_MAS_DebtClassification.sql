CREATE TABLE [AVL].[DEBT_MAS_DebtClassification] (
    [DebtClassificationID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [DebtClassificationName] NVARCHAR (50) NOT NULL,
    [IsDeleted]              BIT           NOT NULL,
    [CreatedBy]              NVARCHAR (50) NOT NULL,
    [CreatedDate]            DATETIME      CONSTRAINT [DF_DEPT_MAS_DebtClassification_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]             NVARCHAR (50) NULL,
    [ModifiedDate]           DATETIME      NULL,
    CONSTRAINT [PK_DEPT_MAS_DebtClassification] PRIMARY KEY CLUSTERED ([DebtClassificationID] ASC)
);

