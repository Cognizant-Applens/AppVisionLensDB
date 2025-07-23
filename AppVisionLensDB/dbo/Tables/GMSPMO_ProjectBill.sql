CREATE TABLE [dbo].[GMSPMO_ProjectBill] (
    [Project_ID]         CHAR (15)    NOT NULL,
    [ACCOUNT_ID]         CHAR (15)    NULL,
    [ACCOUNT_NAME]       VARCHAR (80) NULL,
    [Customer_ID]        VARCHAR (35) NULL,
    [Billability_Type]   VARCHAR (3)  NULL,
    [Project_Start_Date] DATETIME     NOT NULL,
    [Project_End_Date]   DATETIME     NOT NULL,
    [RefreshDate]        DATETIME     NOT NULL,
    [CreatedBy]          VARCHAR (20) NULL
);

