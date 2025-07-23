CREATE TABLE [PP].[Project_PODDetails] (
    [PODDetailID]  BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]    BIGINT         NOT NULL,
    [PODName]      NVARCHAR (250) NOT NULL,
    [PODSize]      SMALLINT       NOT NULL,
    [IsDeleted]    BIT            NOT NULL,
    [CreatedBy]    NVARCHAR (50)  NOT NULL,
    [CreatedDate]  DATETIME       NOT NULL,
    [ModifiedBy]   NVARCHAR (50)  NULL,
    [ModifiedDate] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([PODDetailID] ASC),
    FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);

