CREATE TABLE [SA].[InfrastructureTransaction] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [ApplicationId]    BIGINT         NOT NULL,
    [CapturedTime]     DATETIME       NULL,
    [ServerId]         BIGINT         NOT NULL,
    [Status]           NVARCHAR (100) NULL,
    [UtilizationValue] INT            NULL,
    [RedAlertCount]    INT            NULL,
    [AmberAlertCount]  INT            NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_InfrastructureTransaction_InfrastructureMaster] FOREIGN KEY ([ServerId]) REFERENCES [SA].[InfrastructureMaster] ([ServerId])
);

