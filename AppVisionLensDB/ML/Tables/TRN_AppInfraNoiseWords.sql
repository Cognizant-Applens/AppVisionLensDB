CREATE TABLE [ML].[TRN_AppInfraNoiseWords] (
    [AppInfraNoiseWordId]    BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]              BIGINT         NULL,
    [TowerId]                BIGINT         NULL,
    [ApplicationId]          BIGINT         NULL,
    [TicketDescNoiseWord]    NVARCHAR (500) NULL,
    [Frequency]              INT            NULL,
    [IsUserCreated]          BIT            NOT NULL,
    [IsDeleted]              BIT            NOT NULL,
    [IsActive]               BIT            NOT NULL,
    [CreatedBy]              NVARCHAR (50)  NOT NULL,
    [CreatedDate]            DATETIME       NOT NULL,
    [ModifiedBy]             NVARCHAR (50)  NULL,
    [ModifiedDate]           DATETIME       NULL,
    [OptionalFieldNoiseWord] NVARCHAR (500) NULL,
    [IsAppInfra]             SMALLINT       NULL,
    [OptionalFieldFrequency] INT            NULL,
    [IsActiveResolution]     BIT            CONSTRAINT [DF_TRN_AppInfraNoiseWords_IsActiveResolution] DEFAULT ((0)) NULL,
    CONSTRAINT [PK__TRN_AppI__0A3861C6F89D1EFD] PRIMARY KEY CLUSTERED ([AppInfraNoiseWordId] ASC),
    CONSTRAINT [FK__TRN_AppIn__Appli__3036FEA3] FOREIGN KEY ([ApplicationId]) REFERENCES [AVL].[APP_MAS_ApplicationDetails] ([ApplicationID]),
    CONSTRAINT [FK__TRN_AppIn__Tower__312B22DC] FOREIGN KEY ([TowerId]) REFERENCES [AVL].[InfraTowerDetailsTransaction] ([InfraTowerTransactionID])
);

