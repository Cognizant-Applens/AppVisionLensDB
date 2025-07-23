CREATE TYPE [dbo].[TVP_AdoptionParentProjectDetails] AS TABLE (
    [ESAProjectID]                   NVARCHAR (50)  NOT NULL,
    [AccountId]                      NVARCHAR (50)  NOT NULL,
    [ParentAccountID]                NVARCHAR (50)  NULL,
    [Market]                         NVARCHAR (200) NULL,
    [FinalScope]                     NVARCHAR (100) NOT NULL,
    [IsPerformanceSharingRestricted] BIT            NOT NULL);

