CREATE TABLE [dbo].[TicketUploadProjectConfiguration] (
    [TicketUploadPrjConfigID] BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]               BIGINT         NULL,
    [IsManualOrAuto]          CHAR (1)       NULL,
    [SharePath]               NVARCHAR (200) NULL,
    [Ismailer]                CHAR (1)       NULL,
    [TicketSharePathUsers]    VARCHAR (100)  NULL,
    [IsDeleted]               BIT            NULL,
    [CreatedBy]               VARCHAR (10)   NULL,
    [CreatedDateTime]         DATETIME       NULL,
    [ModifiedBy]              VARCHAR (10)   NULL,
    [ModifiedDateTime]        DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([TicketUploadPrjConfigID] ASC),
    FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);


GO
CREATE NONCLUSTERED INDEX [IDX_IsManOrAuto_IsDeleted]
    ON [dbo].[TicketUploadProjectConfiguration]([IsManualOrAuto] ASC, [IsDeleted] ASC)
    INCLUDE([ProjectID], [SharePath]);


GO
CREATE NONCLUSTERED INDEX [IDX_PrjID_IsDeleted]
    ON [dbo].[TicketUploadProjectConfiguration]([ProjectID] ASC, [IsDeleted] ASC);

