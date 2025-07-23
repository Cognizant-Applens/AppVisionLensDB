CREATE TABLE [AVL].[TK_TRN_Multilingual_TranslatedInfraTicketDetails] (
    [ID]                         BIGINT          IDENTITY (1, 1) NOT NULL,
    [TimeTickerID]               BIGINT          NOT NULL,
    [TicketDescription]          NVARCHAR (MAX)  NULL,
    [ResolutionRemarks]          NVARCHAR (MAX)  NULL,
    [TicketSummary]              NVARCHAR (MAX)  NULL,
    [Comments]                   NVARCHAR (1000) NULL,
    [FlexField1]                 NVARCHAR (MAX)  NULL,
    [FlexField2]                 NVARCHAR (MAX)  NULL,
    [FlexField3]                 NVARCHAR (MAX)  NULL,
    [FlexField4]                 NVARCHAR (MAX)  NULL,
    [Category]                   NVARCHAR (MAX)  NULL,
    [Type]                       NVARCHAR (MAX)  NULL,
    [IsTicketDescriptionUpdated] BIT             NULL,
    [IsResolutionRemarksUpdated] BIT             NULL,
    [IsTicketSummaryUpdated]     BIT             NULL,
    [IsCommentsUpdated]          BIT             NULL,
    [IsFlexField1Updated]        BIT             NULL,
    [IsFlexField2Updated]        BIT             NULL,
    [IsFlexField3Updated]        BIT             NULL,
    [IsFlexField4Updated]        BIT             NULL,
    [IsCategoryUpdated]          BIT             NULL,
    [IsTypeUpdated]              BIT             NULL,
    [CreatedBy]                  NVARCHAR (50)   NOT NULL,
    [CreatedDate]                DATETIME        NOT NULL,
    [ModifiedBy]                 NVARCHAR (50)   NULL,
    [ModifiedDate]               DATETIME        NULL,
    [Isdeleted]                  BIT             NULL,
    [TicketCreatedType]          INT             NULL,
    [ReferenceID]                BIGINT          NULL
);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER18_TK_TRN_Multilingual_TranslatedInfraTicketDetails_TimeTickerID]
    ON [AVL].[TK_TRN_Multilingual_TranslatedInfraTicketDetails]([TimeTickerID] ASC)
    INCLUDE([ID], [TicketDescription], [ResolutionRemarks], [TicketSummary], [Comments], [Category], [IsTicketDescriptionUpdated], [IsTicketSummaryUpdated], [IsCommentsUpdated], [IsFlexField1Updated], [IsFlexField2Updated], [IsFlexField3Updated], [IsFlexField4Updated], [IsCategoryUpdated], [IsTypeUpdated]);


GO
CREATE NONCLUSTERED INDEX [NONCLUSTER2_TK_TRN_Multilingual_TranslatedInfraTicketDetails_TimeTickerID]
    ON [AVL].[TK_TRN_Multilingual_TranslatedInfraTicketDetails]([TimeTickerID] ASC)
    INCLUDE([ID], [TicketDescription], [ResolutionRemarks], [IsTicketDescriptionUpdated]);

