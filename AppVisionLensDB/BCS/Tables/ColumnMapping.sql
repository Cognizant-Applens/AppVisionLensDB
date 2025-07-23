CREATE TABLE [BCS].[ColumnMapping] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [UserId]           INT            NOT NULL,
    [ESAProjectID]     BIGINT         NOT NULL,
    [ProjectID]        BIGINT         NOT NULL,
    [ProjectName]      NVARCHAR (MAX) NOT NULL,
    [ApplensColumnID]  INT            NOT NULL,
    [RemedyColumn]     NVARCHAR (MAX) NULL,
    [ServiceNowColumn] NVARCHAR (MAX) NULL,
    [OtherITSMColumn]  NVARCHAR (MAX) NULL,
    [CreatedAt]        DATETIME       DEFAULT (getdate()) NOT NULL,
    [CreatedBy]        NVARCHAR (MAX) NOT NULL,
    [UpdatedAt]        DATETIME       DEFAULT (getdate()) NOT NULL,
    [UpdatedBy]        NVARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_AppColID] FOREIGN KEY ([ApplensColumnID]) REFERENCES [BCS].[TicketTemplateApplensColumns] ([ApplensColumnID])
);

