CREATE TABLE [AVL].[MAS_TimesheetStatus] (
    [TimesheetStatusId] INT          IDENTITY (1, 1) NOT NULL,
    [TimesheetStatus]   VARCHAR (25) NULL,
    [CreatedBy]         NUMERIC (6)  NULL,
    [CreatedDateTime]   DATETIME     NULL,
    [ModifiedBy]        NUMERIC (6)  NULL,
    [ModifiedDateTime]  DATETIME     NULL,
    [IsDeleted]         BIT          NOT NULL,
    PRIMARY KEY CLUSTERED ([TimesheetStatusId] ASC)
);

