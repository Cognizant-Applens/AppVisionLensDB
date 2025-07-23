CREATE TABLE [AVL].[DEBT_TRN_TimesheetOfflineSyncLog] (
    [LogID]           INT           IDENTITY (1, 1) NOT NULL,
    [TicketInsert]    INT           NULL,
    [TicketUpdate]    INT           NULL,
    [TimesheetInsert] INT           NULL,
    [TimesheetUpdate] INT           NULL,
    [StartDateTime]   DATETIME      NULL,
    [EndDateTime]     DATETIME      NULL,
    [IsDeleted]       BIT           NULL,
    [CreatedDate]     DATETIME      NULL,
    [CreatedBy]       NVARCHAR (20) NULL,
    [ModifiedDate]    DATETIME      NULL,
    [ModifiedBy]      NVARCHAR (20) NULL
);

