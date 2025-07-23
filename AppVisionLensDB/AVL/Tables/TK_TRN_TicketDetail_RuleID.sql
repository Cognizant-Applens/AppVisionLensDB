CREATE TABLE [AVL].[TK_TRN_TicketDetail_RuleID] (
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


GO
CREATE NONCLUSTERED INDEX [IX_TicketDetail_RuleID]
    ON [AVL].[TK_TRN_TicketDetail_RuleID]([RuleID] ASC)
    INCLUDE([TimeTickerID]);


GO
CREATE NONCLUSTERED INDEX [NC_TK_TRN_TicketDetail_RuleID_TimeTickerID]
    ON [AVL].[TK_TRN_TicketDetail_RuleID]([TimeTickerID] ASC)
    INCLUDE([RuleID]);

