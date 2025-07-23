CREATE TABLE [AVL].[MAS_ITSMToolConfiguration] (
    [ID]           INT             IDENTITY (1, 1) NOT NULL,
    [ITSMToolID]   INT             NULL,
    [ITSMScreenID] INT             NULL,
    [Value]        NVARCHAR (1000) NULL,
    [IsDeleted]    BIT             NULL,
    [CreatedBy]    NVARCHAR (MAX)  NULL,
    [CreatedDate]  DATETIME        NULL,
    [ColMappingID] INT             NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

