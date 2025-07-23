CREATE TABLE [dbo].[ErrorLogDetails] (
    [Id]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [LogSeverity]       VARCHAR (50)   NULL,
    [LogLevel]          VARCHAR (50)   NULL,
    [HostName]          NVARCHAR (200) NOT NULL,
    [AssociateId]       NVARCHAR (50)  NULL,
    [CreatedDate]       DATETIME       DEFAULT (getdate()) NOT NULL,
    [ProjectId]         NVARCHAR (50)  NULL,
    [ModuleName]        NVARCHAR (250) NULL,
    [FeatureName]       NVARCHAR (250) NULL,
    [ClassName]         NVARCHAR (250) NULL,
    [MethodName]        NVARCHAR (250) NULL,
    [ProcessId]         BIGINT         NULL,
    [ErrorCode]         VARCHAR (50)   NULL,
    [ErrorMessage]      NVARCHAR (MAX) NULL,
    [StackTrace]        NVARCHAR (MAX) NULL,
    [AdditionalField_1] NVARCHAR (MAX) NULL,
    [AdditionalField_2] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_ErrorLogDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);

