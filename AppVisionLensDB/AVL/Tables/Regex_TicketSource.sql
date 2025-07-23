CREATE TABLE [AVL].[Regex_TicketSource] (
    [ID]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [RegexJobStatusID]    BIGINT         NULL,
    [ProjectID]           BIGINT         NULL,
    [TicketID]            NVARCHAR (50)  NULL,
    [RegexField]          NVARCHAR (MAX) NULL,
    [StaticOutput]        NVARCHAR (MAX) NULL,
    [DynamicJobOutput]    NVARCHAR (MAX) NULL,
    [DynamicServerOutput] NVARCHAR (MAX) NULL,
    [DynamicCustomOutput] NVARCHAR (MAX) NULL,
    [IsDeleted]           BIT            NOT NULL,
    [CreatedBy]           NVARCHAR (50)  NOT NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [ModifiedBy]          NVARCHAR (50)  NULL,
    [ModifiedDate]        DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_RegexJobStatusID] FOREIGN KEY ([RegexJobStatusID]) REFERENCES [AVL].[RegexJobStatus] ([ID]),
    CONSTRAINT [FK_RegexTicketSource_ProjectID] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

