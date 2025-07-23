CREATE TABLE [ML].[WorkPatternConfiguration] (
    [ID]                           BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]                    BIGINT         NOT NULL,
    [TicketDescriptionBasePattern] NVARCHAR (250) NOT NULL,
    [TicketDescriptionSubPattern]  NVARCHAR (250) NOT NULL,
    [ResolutionRemarksBasePattern] NVARCHAR (250) NOT NULL,
    [ResolutionRemarksSubPattern]  NVARCHAR (250) NOT NULL,
    [IsDeleted]                    BIT            NOT NULL,
    [CreatedBy]                    NVARCHAR (50)  NULL,
    [CreatedDate]                  DATETIME       NULL,
    [ModifiedBy]                   NVARCHAR (50)  NULL,
    [ModifiedDate]                 DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

