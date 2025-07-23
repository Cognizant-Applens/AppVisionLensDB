CREATE TABLE [AVL].[ProjectServiceTypeFTE] (
    [ID]            BIGINT          IDENTITY (1, 1) NOT NULL,
    [ProjectID]     BIGINT          NOT NULL,
    [ServiceTypeID] SMALLINT        NOT NULL,
    [FTEPercenatge] DECIMAL (10, 2) NOT NULL,
    [IsDeleted]     BIT             NOT NULL,
    [CreatedBy]     NVARCHAR (50)   NOT NULL,
    [CreatedDate]   DATETIME        NOT NULL,
    [ModifiedBy]    NVARCHAR (50)   NULL,
    [ModifiedDate]  DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID]),
    FOREIGN KEY ([ServiceTypeID]) REFERENCES [MAS].[ServiceCategory] ([CategoryID])
);

