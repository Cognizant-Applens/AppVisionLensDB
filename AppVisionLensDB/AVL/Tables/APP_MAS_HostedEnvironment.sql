CREATE TABLE [AVL].[APP_MAS_HostedEnvironment] (
    [HostedEnvironmentID]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [HostedEnvironmentName] NVARCHAR (50) NOT NULL,
    [Isdeleted]             BIT           NOT NULL,
    [CreatedBy]             NCHAR (10)    NOT NULL,
    [CreatedDate]           DATETIME      CONSTRAINT [DF_APP_hosted_Environment_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [ModifiedBy]            NCHAR (10)    NULL,
    [ModifiedDate]          DATETIME      NULL,
    CONSTRAINT [PK_APP_hosted_Environment] PRIMARY KEY CLUSTERED ([HostedEnvironmentID] ASC)
);

