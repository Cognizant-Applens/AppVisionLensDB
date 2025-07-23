CREATE TABLE [AVL].[ProjectArchivalLog] (
    [ProjectArchivalLogID] BIGINT         IDENTITY (1, 1) NOT NULL,
    [ArchivalLogID]        BIGINT         NOT NULL,
    [ProjectID]            BIGINT         NULL,
    [ESAProjectID]         NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([ProjectArchivalLogID] ASC)
);

