CREATE TABLE [AVL].[TicketUploadTrackDetails] (
    [TicketUploadTrackDetailsID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [TicketUploadTrackID]        BIGINT        NULL,
    [DetailMessage]              VARCHAR (MAX) NULL,
    [CreatedDate]                DATETIME      NULL
);

