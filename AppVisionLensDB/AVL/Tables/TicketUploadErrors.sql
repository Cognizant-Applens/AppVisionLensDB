CREATE TABLE [AVL].[TicketUploadErrors] (
    [ErrorID]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [EmployeeID]       NVARCHAR (50)  NULL,
    [ProjectID]        VARCHAR (50)   NULL,
    [CustomerID]       VARCHAR (50)   NULL,
    [Error_Details]    VARCHAR (8000) NULL,
    [UploadedFileName] VARCHAR (8000) NULL,
    [CreatedOn]        DATETIME       NULL,
    CONSTRAINT [PK_TicketUploadErrors] PRIMARY KEY CLUSTERED ([ErrorID] ASC)
);

