CREATE TABLE [ESA].[ProjectAssociates] (
    [ID]                    INT            IDENTITY (1, 1) NOT NULL,
    [AssociateID]           CHAR (11)      NOT NULL,
    [ProjectID]             INT            NOT NULL,
    [AllocationStartDate]   DATE           NULL,
    [AllocationEndDate]     DATE           NULL,
    [AllocationPercent]     FLOAT (53)     NULL,
    [LastModifiedDate]      DATE           NULL,
    [ACCOUNT_ID]            CHAR (15)      NULL,
    [ACCOUNT_NAME]          VARCHAR (60)   NULL,
    [CTS_VERTICAL]          CHAR (10)      NULL,
    [Project_Small_Desc]    VARCHAR (274)  NULL,
    [Allocation_Percentage] NUMERIC (5, 2) NULL,
    [Dept_Name]             VARCHAR (30)   NULL,
    [Grade]                 CHAR (3)       NULL,
    [City]                  VARCHAR (50)   NULL,
    CONSTRAINT [PK_ProjectAssocates] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);


GO
CREATE NONCLUSTERED INDEX [IX_PROJ_PROJECTID]
    ON [ESA].[ProjectAssociates]([ProjectID] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-Adp_Project_Compliance_AVM-GetUserManagementDetailsByProjectid1]
    ON [ESA].[ProjectAssociates]([ACCOUNT_ID] ASC)
    INCLUDE([AssociateID]);

