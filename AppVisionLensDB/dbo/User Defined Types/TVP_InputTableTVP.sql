CREATE TYPE [dbo].[TVP_InputTableTVP] AS TABLE (
    [ProjectID]         BIGINT         NULL,
    [TicketID]          NVARCHAR (MAX) NULL,
    [TrackID]           NVARCHAR (MAX) NULL,
    [ServiceName]       VARCHAR (MAX)  NULL,
    [ActivityName]      VARCHAR (MAX)  NULL,
    [TicketType]        VARCHAR (MAX)  NULL,
    [CognizantID]       VARCHAR (MAX)  NULL,
    [IsCognizant]       BIT            NULL,
    [Hours]             VARCHAR (MAX)  NULL,
    [TimeSheetDate]     DATE           NULL,
    [Remarks]           NVARCHAR (MAX) NULL,
    [SuggestedActivity] NVARCHAR (50)  NULL,
    [Type]              NVARCHAR (10)  NULL);

