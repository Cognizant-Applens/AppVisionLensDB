CREATE TABLE [dbo].[InsertMissedTicket] (
    [Project ID]          NVARCHAR (500) NULL,
    [projectname]         NVARCHAR (500) NOT NULL,
    [Ticket ID]           NVARCHAR (500) NULL,
    [Application]         NVARCHAR (500) NULL,
    [service]             NVARCHAR (500) NULL,
    [Ticket Type]         NVARCHAR (500) NULL,
    [AppLens Ticket Type] NVARCHAR (500) NULL,
    [Priority]            NVARCHAR (500) NULL,
    [Assignment Group]    NVARCHAR (500) NULL,
    [Applicationid]       BIGINT         NULL,
    [serviceid]           BIGINT         NULL,
    [causeid]             BIGINT         NULL,
    [resolutionid]        BIGINT         NULL,
    [priorityid]          BIGINT         NULL,
    [assignmentgroupid]   BIGINT         NULL,
    [severityid]          BIGINT         NULL,
    [ticketstatusid]      BIGINT         NULL,
    [dartstatusid]        BIGINT         NULL,
    [tickettypemapid]     BIGINT         NULL,
    [project_id]          BIGINT         NULL,
    [opendate]            DATETIME       NULL
);

