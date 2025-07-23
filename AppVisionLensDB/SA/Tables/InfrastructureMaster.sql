CREATE TABLE [SA].[InfrastructureMaster] (
    [ServerId]                    BIGINT         IDENTITY (1, 1) NOT NULL,
    [ServerType]                  NVARCHAR (100) NOT NULL,
    [ServerName]                  NVARCHAR (100) NOT NULL,
    [SharedServer]                INT            NOT NULL,
    [InfrastructureApplicationId] BIGINT         NOT NULL,
    [ServerIPAaddress]            NVARCHAR (100) NOT NULL,
    [ServiceUsername]             NVARCHAR (100) NOT NULL,
    [ServicePassword]             NVARCHAR (100) NOT NULL,
    [DatabaseName]                NVARCHAR (100) NULL,
    [DatabasePort]                NVARCHAR (100) NULL,
    [DatabaseUsername]            NVARCHAR (100) NULL,
    [DatabasePassword]            NVARCHAR (100) NULL,
    [CPURedPercentage]            INT            NOT NULL,
    [CPUAmberPercentage]          INT            NOT NULL,
    [DiskRedPercentage]           INT            NOT NULL,
    [DiskAmberPercentage]         INT            NOT NULL,
    [MemoryRedPercentage]         INT            NOT NULL,
    [MemoryAmberPercentage]       INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([ServerId] ASC)
);

