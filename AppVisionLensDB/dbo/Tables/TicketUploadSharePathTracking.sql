CREATE TABLE [dbo].[TicketUploadSharePathTracking] (
    [ID]            INT           IDENTITY (1, 1) NOT NULL,
    [ProjectID]     BIGINT        NULL,
    [MessageString] VARCHAR (MAX) NULL,
    [CreatedBy]     VARCHAR (50)  DEFAULT ('SharePath') NULL,
    [CreatedOn]     DATETIME      DEFAULT (getdate()) NULL
);

