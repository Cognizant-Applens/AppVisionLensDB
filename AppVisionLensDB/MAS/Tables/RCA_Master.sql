CREATE TABLE [MAS].[RCA_Master] (
    [ID]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [RCANumber]          VARCHAR (50)   NOT NULL,
    [RCA]                NVARCHAR (250) NOT NULL,
    [AppPriority]        VARCHAR (10)   NULL,
    [App_RCA]            BIT            NULL,
    [AppResolution]      TEXT           NULL,
    [InfraPriority]      VARCHAR (10)   NULL,
    [Infra_RCA]          BIT            NULL,
    [InfraResolution]    TEXT           NULL,
    [SecurityPriority]   VARCHAR (10)   NULL,
    [Security_RCA]       BIT            NULL,
    [SecurityResolution] TEXT           NULL,
    [IsDeleted]          BIT            NOT NULL,
    [CreatedDate]        DATETIME       NOT NULL,
    [CreatedBy]          NVARCHAR (50)  NOT NULL,
    [ModifiedDate]       DATETIME       NULL,
    [ModifiedBy]         NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

