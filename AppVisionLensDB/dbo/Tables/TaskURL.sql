CREATE TABLE [dbo].[TaskURL] (
    [TaskURLID]    BIGINT        IDENTITY (1, 1) NOT NULL,
    [TaskID]       INT           NULL,
    [TaskURL]      VARCHAR (MAX) NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    VARCHAR (100) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   VARCHAR (100) NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([TaskURLID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_TaskID_IsDeleted]
    ON [dbo].[TaskURL]([TaskID] ASC, [IsDeleted] ASC);

