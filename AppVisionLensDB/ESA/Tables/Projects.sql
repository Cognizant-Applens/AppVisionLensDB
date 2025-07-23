CREATE TABLE [ESA].[Projects] (
    [ID]                 INT           NOT NULL,
    [AccountID]          INT           NOT NULL,
    [Name]               VARCHAR (255) NOT NULL,
    [ProjectType]        NCHAR (10)    NULL,
    [ProjectStartDate]   DATETIME      NULL,
    [ProjectEndDate]     DATETIME      NULL,
    [CustomerName]       VARCHAR (100) NULL,
    [BillabilityType]    VARCHAR (10)  NULL,
    [ProjectStatus]      VARCHAR (50)  NULL,
    [LastModifiedDate]   DATETIME      NULL,
    [ProjectManagerID]   VARCHAR (30)  NULL,
    [AccountManagerID]   VARCHAR (30)  NULL,
    [Project_Small_Desc] VARCHAR (274) NULL,
    [CTS_VERTICAL]       CHAR (10)     NULL,
    CONSTRAINT [PK_Projects] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);

