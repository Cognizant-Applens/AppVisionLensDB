CREATE TABLE [AVL].[MAS_KTicketCancelOptions] (
    [OptionID]     BIGINT        IDENTITY (1, 1) NOT NULL,
    [OptionName]   NVARCHAR (50) NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      CONSTRAINT [DF_APP_MAS_KTicketCancelOptions_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    CONSTRAINT [PK_APP_MAS_KTicketCancelOptions] PRIMARY KEY CLUSTERED ([OptionID] ASC)
);

