CREATE TABLE [dbo].[AVMDART_MigratedProjectsInfo] (
    [ESAAccountID]              BIGINT         NULL,
    [DARTAccountName]           NVARCHAR (200) NULL,
    [AppLensCustomerName]       NVARCHAR (200) NULL,
    [ESAProjectID]              BIGINT         NULL,
    [DARTProjectID]             BIGINT         NULL,
    [AppLensProjectID]          BIGINT         NULL,
    [DARTProjectName]           NVARCHAR (200) NULL,
    [AppLensProjectName]        NVARCHAR (200) NULL,
    [MigratedDate]              DATE           NULL,
    [TicketMaxLastModifiedDate] DATETIME       NULL,
    [TimesheetMaxCreatedDate]   DATETIME       NULL,
    [TimesheetMaxModifiedDate]  DATETIME       NULL,
    [OperationalDate]           DATETIME       NULL
);

