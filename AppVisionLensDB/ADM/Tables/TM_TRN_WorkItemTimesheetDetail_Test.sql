CREATE TABLE [ADM].[TM_TRN_WorkItemTimesheetDetail_Test] (
    [TimesheetDetailID]   BIGINT         IDENTITY (1, 1) NOT NULL,
    [TimeSheetId]         BIGINT         NOT NULL,
    [WorkItemDetailsId]   BIGINT         NULL,
    [ServiceID]           INT            NULL,
    [ActivityID]          INT            NULL,
    [Hours]               DECIMAL (5, 2) NULL,
    [IsNonTicket]         BIT            NOT NULL,
    [SuggestedActivityID] BIGINT         NULL,
    [Remarks]             NVARCHAR (250) NULL,
    [IsDeleted]           BIT            NOT NULL,
    [CreatedBy]           NVARCHAR (50)  NOT NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [ModifiedBy]          NVARCHAR (50)  NULL,
    [ModifiedDate]        DATETIME       NULL
);

