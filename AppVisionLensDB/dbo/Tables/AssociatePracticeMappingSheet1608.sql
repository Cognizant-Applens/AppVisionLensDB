CREATE TABLE [dbo].[AssociatePracticeMappingSheet1608] (
    [projectID]             CHAR (15)      NULL,
    [projectname]           VARCHAR (274)  NULL,
    [AccountID]             CHAR (15)      NULL,
    [AccountName]           VARCHAR (80)   NULL,
    [Associate_ID]          CHAR (11)      NOT NULL,
    [Associate_Name]        VARCHAR (302)  NULL,
    [Allocation_Start_Date] DATETIME       NULL,
    [Allocation_End_Date]   DATETIME       NULL,
    [Allocation_Percentage] NUMERIC (5, 2) NULL,
    [Grade]                 CHAR (3)       NULL,
    [Dept_Name]             VARCHAR (30)   NULL,
    [Supervisor_ID]         VARCHAR (31)   NULL,
    [Supervisor_Name]       VARCHAR (302)  NULL,
    [projectstatus]         VARCHAR (1)    NULL,
    [Assignment_Status]     CHAR (1)       NULL,
    [OPL Practice]          NVARCHAR (255) NULL
);

