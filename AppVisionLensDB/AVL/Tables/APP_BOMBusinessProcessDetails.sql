CREATE TABLE [AVL].[APP_BOMBusinessProcessDetails] (
    [BusinessProcessID]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [BusinessProcess]             NVARCHAR (50) NOT NULL,
    [ParentBusinessProcessID]     BIGINT        NOT NULL,
    [IsHavingSubBusinesssProcess] BIT           NOT NULL,
    [MapID]                       INT           NULL,
    [SourceID]                    INT           NULL,
    [IsDeleted]                   BIT           NOT NULL,
    [CreatedBy]                   NVARCHAR (50) NOT NULL,
    [CreatedDate]                 DATETIME      CONSTRAINT [DF_BOMApplicationDetail_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]                  NVARCHAR (50) NULL,
    [ModifiedDate]                DATETIME      NULL,
    CONSTRAINT [PK_BOMApplicationDetail] PRIMARY KEY CLUSTERED ([BusinessProcessID] ASC)
);

