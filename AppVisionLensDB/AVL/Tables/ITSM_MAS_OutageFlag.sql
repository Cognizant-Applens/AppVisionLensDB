CREATE TABLE [AVL].[ITSM_MAS_OutageFlag] (
    [OutageFlagId] INT           IDENTITY (1, 1) NOT NULL,
    [Outage Flag]  VARCHAR (100) NULL,
    [CreatedBy]    NUMERIC (6)   NULL,
    [CreatedDate]  DATETIME      NULL,
    [ModifiedBy]   NUMERIC (6)   NULL,
    [ModifiedDate] DATETIME      NULL,
    [IsDeleted]    BIT           NULL
);

