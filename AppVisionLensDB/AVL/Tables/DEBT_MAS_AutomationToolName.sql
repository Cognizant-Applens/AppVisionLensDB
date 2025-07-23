CREATE TABLE [AVL].[DEBT_MAS_AutomationToolName] (
    [ToolId]         BIGINT         IDENTITY (1, 1) NOT NULL,
    [SolutionTypeID] BIGINT         NULL,
    [ToolName]       NVARCHAR (200) NULL,
    [IsDeleted]      BIT            NULL,
    [CreatedBy]      NVARCHAR (50)  NULL,
    [CreatedDate]    DATETIME       NULL,
    [ModifiedBy]     NVARCHAR (50)  NULL,
    [ModifiedDate]   DATETIME       NULL,
    CONSTRAINT [PK__DEBT_MAS__CC0CEB91104FD465] PRIMARY KEY CLUSTERED ([ToolId] ASC),
    CONSTRAINT [FK__DEBT_MAS___Solut__44AE3492] FOREIGN KEY ([SolutionTypeID]) REFERENCES [AVL].[TK_MAS_SolutionType] ([SolutionTypeID])
);

