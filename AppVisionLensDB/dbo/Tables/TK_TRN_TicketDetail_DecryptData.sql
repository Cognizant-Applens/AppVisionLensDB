CREATE TABLE [dbo].[TK_TRN_TicketDetail_DecryptData] (
    [TimeTickerID]               BIGINT         NULL,
    [TicketID]                   VARCHAR (200)  NULL,
    [ProjectID]                  BIGINT         NULL,
    [ESAProjectID]               BIGINT         NULL,
    [ApplicationName]            VARCHAR (MAX)  NULL,
    [Efforts]                    BIGINT         NULL,
    [DecryptedTicketDescription] VARCHAR (MAX)  NULL,
    [ErrorMessage]               VARCHAR (MAX)  NULL,
    [ResolutionRemarks]          NVARCHAR (MAX) NULL
);

