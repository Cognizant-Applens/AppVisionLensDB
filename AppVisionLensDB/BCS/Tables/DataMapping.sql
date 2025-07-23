CREATE TABLE [BCS].[DataMapping] (
    [ID]              INT            IDENTITY (1, 1) NOT NULL,
    [UserId]          INT            NOT NULL,
    [ESAProjectID]    BIGINT         NOT NULL,
    [ProjectID]       BIGINT         NOT NULL,
    [ProjectName]     NVARCHAR (MAX) NOT NULL,
    [ApplensColumnID] INT            NOT NULL,
    [AppLensDataID]   NVARCHAR (MAX) NOT NULL,
    [RemedyData]      NVARCHAR (MAX) NOT NULL,
    [ServiceData]     NVARCHAR (MAX) NOT NULL,
    [OtherData]       NVARCHAR (MAX) NOT NULL,
    [CreatedAt]       DATETIME       NOT NULL,
    [CreatedBy]       NVARCHAR (MAX) NOT NULL,
    [UpdatedAt]       DATETIME       NOT NULL,
    [UpdatedBy]       NVARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_AppColumnID] FOREIGN KEY ([ApplensColumnID]) REFERENCES [BCS].[TicketTemplateApplensColumns] ([ApplensColumnID])
);

