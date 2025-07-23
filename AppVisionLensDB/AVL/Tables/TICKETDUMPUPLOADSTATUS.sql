CREATE TABLE [AVL].[TICKETDUMPUPLOADSTATUS] (
    [LogID]               INT            IDENTITY (1, 1) NOT NULL,
    [UserID]              NVARCHAR (100) NULL,
    [ProjectID]           INT            NULL,
    [TotalTicketCount]    INT            NULL,
    [UpdatedticketCount]  INT            NULL,
    [ReuploadticketCount] INT            NULL,
    [FailedticketCount]   INT            NULL,
    [Uploadstarttime]     DATETIME       NULL,
    [Uploadendtime]       DATETIME       NULL,
    [UploadMode]          VARCHAR (100)  NULL,
    [Status]              VARCHAR (100)  NULL,
    [FileName]            VARCHAR (500)  NULL,
    [Remarks]             VARCHAR (500)  NULL,
    [ErrorFileName]       VARCHAR (100)  NULL,
    [IsGracePeriodMet]    BIT            DEFAULT ((0)) NULL
);

