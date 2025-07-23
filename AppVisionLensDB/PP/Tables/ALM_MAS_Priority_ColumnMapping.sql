CREATE TABLE [PP].[ALM_MAS_Priority_ColumnMapping] (
    [PriorityMappingId]   INT           IDENTITY (1, 1) NOT NULL,
    [PriorityMappingName] VARCHAR (50)  NOT NULL,
    [IsDeleted]           BIT           NOT NULL,
    [CreatedBy]           NVARCHAR (50) NOT NULL,
    [CreatedDate]         DATETIME      NOT NULL,
    [ModifiedBy]          NVARCHAR (50) NULL,
    [ModifiedDate]        DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([PriorityMappingId] ASC)
);

