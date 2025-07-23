CREATE TABLE [LW].[RuleApprovalDetails] (
    [TransRecordID] BIGINT        NOT NULL,
    [RuleStatus]    INT           DEFAULT (NULL) NULL,
    [ApprovedDate]  DATETIME      DEFAULT (getdate()) NULL,
    [ApprovedBy]    NVARCHAR (50) DEFAULT (NULL) NULL,
    [MutedDate]     DATETIME      DEFAULT (getdate()) NULL,
    [MutedBy]       NVARCHAR (50) DEFAULT (NULL) NULL,
    [IsDeleted]     BIT           NOT NULL,
    [CreatedDate]   DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedBy]     NVARCHAR (50) DEFAULT (NULL) NOT NULL,
    [ModifiedDate]  DATETIME      DEFAULT (getdate()) NULL,
    [ModifiedBy]    NVARCHAR (50) DEFAULT (NULL) NULL,
    PRIMARY KEY CLUSTERED ([TransRecordID] ASC)
);

