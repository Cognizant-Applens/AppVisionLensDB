CREATE TABLE [SA].[InformationMaster] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [ApplicationId] BIGINT         NOT NULL,
    [TechnologyId]  BIGINT         NULL,
    [ProcessName]   NVARCHAR (100) NOT NULL,
    [BusinessArea]  NVARCHAR (100) NOT NULL,
    [StartTime]     TIME (7)       NULL,
    [EndTime]       TIME (7)       NULL,
    [Duration]      INT            NULL,
    [RunFrequency]  VARCHAR (30)   NULL,
    [Geographic]    NVARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_InformationMaster_APP_MAS_ApplicationDetails] FOREIGN KEY ([ApplicationId]) REFERENCES [AVL].[APP_MAS_ApplicationDetails] ([ApplicationID]),
    CONSTRAINT [FK_InformationMaster_APP_MAS_PrimaryTechnology] FOREIGN KEY ([TechnologyId]) REFERENCES [AVL].[APP_MAS_PrimaryTechnology] ([PrimaryTechnologyID])
);

