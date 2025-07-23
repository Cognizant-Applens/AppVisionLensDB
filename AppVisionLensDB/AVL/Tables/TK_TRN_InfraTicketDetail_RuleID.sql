CREATE TABLE [AVL].[TK_TRN_InfraTicketDetail_RuleID] (
    [ID]                   INT            IDENTITY (1, 1) NOT NULL,
    [TimeTickerID]         BIGINT         NULL,
    [RuleID]               BIGINT         NULL,
    [Createdby]            NVARCHAR (100) NULL,
    [CreatedDate]          DATETIME       NULL,
    [LWRuleID]             BIGINT         NULL,
    [LWRuleLevel]          VARCHAR (50)   NULL,
    [ClusterID_Desc]       INT            NULL,
    [ClusterID_Resolution] INT            NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

