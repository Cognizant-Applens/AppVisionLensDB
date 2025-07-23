CREATE TABLE [ESA].[Associates] (
    [AssociateID]         CHAR (11)      NOT NULL,
    [AssociateName]       VARCHAR (255)  NOT NULL,
    [Designation]         NVARCHAR (200) NOT NULL,
    [Grade]               CHAR (3)       NOT NULL,
    [Email]               NVARCHAR (255) NULL,
    [PassportNo]          VARCHAR (20)   NULL,
    [PassPortIssueDate]   DATE           NULL,
    [PassportExpiryDate]  DATE           NULL,
    [IsActive]            BIT            NOT NULL,
    [LastModifiedDate]    DATETIME       NOT NULL,
    [Supervisor_ID]       VARCHAR (31)   NULL,
    [Supervisor_Name]     VARCHAR (302)  NULL,
    [JobCode]             VARCHAR (50)   NULL,
    [Offshore_Onsite]     VARCHAR (3)    NULL,
    [Assignment_Location] NVARCHAR (12)  NULL,
    [City]                NVARCHAR (50)  NULL,
    [State]               NVARCHAR (6)   NULL,
    [Country]             NVARCHAR (5)   NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_ActiveAssociate]
    ON [ESA].[Associates]([IsActive] ASC)
    INCLUDE([AssociateID], [AssociateName]);


GO
CREATE NONCLUSTERED INDEX [IX_ASSOCIATEID]
    ON [ESA].[Associates]([AssociateID] ASC, [IsActive] ASC)
    INCLUDE([AssociateName], [Email]);

