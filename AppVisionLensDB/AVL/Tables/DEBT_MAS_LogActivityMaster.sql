CREATE TABLE [AVL].[DEBT_MAS_LogActivityMaster] (
    [ActivityID]   INT             IDENTITY (1, 1) NOT NULL,
    [ActivityName] NVARCHAR (1000) NULL,
    [Action]       NVARCHAR (200)  NULL,
    [CreatedBy]    NVARCHAR (50)   NULL,
    [CreatedDate]  DATETIME        NULL,
    [IsDeleted]    BIT             NULL,
    [ModifiedBy]   NVARCHAR (50)   NULL,
    [ModifiedDate] DATETIME        NULL
);

