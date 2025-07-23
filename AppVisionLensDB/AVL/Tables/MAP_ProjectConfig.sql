CREATE TABLE [AVL].[MAP_ProjectConfig] (
    [ProconfigID]                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]                    BIGINT         NOT NULL,
    [Uploadinactiveuser]           NVARCHAR (5)   NULL,
    [Ticketsource]                 NVARCHAR (50)  NULL,
    [Defaultermail]                NVARCHAR (5)   NULL,
    [CreatedBY]                    NVARCHAR (50)  NULL,
    [CreatedDateTime]              DATETIME       NULL,
    [ModifiedBy]                   NVARCHAR (50)  NULL,
    [ModifiedDateTime]             DATETIME       NULL,
    [IsC20DownloadEnabled]         NVARCHAR (10)  NULL,
    [Severity]                     NVARCHAR (50)  NULL,
    [ApprovalMail]                 CHAR (1)       NULL,
    [ApprovalMailStartDay]         INT            NULL,
    [ApprovalMailEndDay]           INT            NULL,
    [ApprovalMailFrequency]        NVARCHAR (20)  NULL,
    [ApproveMailNextDate]          DATE           NULL,
    [AutoUploadCount]              INT            NULL,
    [TimeZoneId]                   INT            NULL,
    [TSSubmitRules]                INT            DEFAULT ((0)) NULL,
    [IsAutoAssigneeForDART]        BIT            NULL,
    [AutoUploadForDARTCount]       INT            NULL,
    [TicketSharePathUsers]         NVARCHAR (200) NULL,
    [TktDfltrMail]                 CHAR (1)       NULL,
    [TktDfltrMailStartDay]         INT            NULL,
    [TktDfltrMailEndDay]           INT            NULL,
    [TktDfltrMailFrequency]        NVARCHAR (20)  NULL,
    [IsEffortFlag]                 CHAR (1)       NULL,
    [IsMandatoryFlag]              CHAR (1)       NULL,
    [TicketdefaulterMailNextDate]  DATETIME       NULL,
    [IsTicketTypeMappedForService] INT            DEFAULT (NULL) NULL,
    [Workinghours]                 DECIMAL (18)   NULL,
    [ReportForAssociates]          BIT            NULL,
    [ReportForSupervisor]          BIT            NULL,
    [SupportTypeId]                INT            NULL,
    CONSTRAINT [PK_MAP_ProjectConfig] PRIMARY KEY CLUSTERED ([ProconfigID] ASC),
    CONSTRAINT [FK_MAP_ProjectConfig_MAS_ProjectMaster] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    CONSTRAINT [IX_MAP_ProjectConfig] UNIQUE NONCLUSTERED ([ProjectID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_MAP_ProjectConfig_ProjectID_TimeZoneId]
    ON [AVL].[MAP_ProjectConfig]([ProjectID] ASC, [TimeZoneId] ASC);

