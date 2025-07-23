CREATE TABLE [AVL].[BusinessUnit] (
    [BUID]         BIGINT        IDENTITY (1, 1) NOT NULL,
    [BUName]       NVARCHAR (50) NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [BUCode]       NVARCHAR (50) NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      CONSTRAINT [DF_BU_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    [IsHorizontal] VARCHAR (5)   NULL,
    CONSTRAINT [PK_BU] PRIMARY KEY CLUSTERED ([BUID] ASC)
);

