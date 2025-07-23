CREATE TABLE [BCS].[TicketTemplateApplensColumns] (
    [ApplensColumnID] INT            IDENTITY (1, 1) NOT NULL,
    [ApplensColumns]  NVARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([ApplensColumnID] ASC)
);

