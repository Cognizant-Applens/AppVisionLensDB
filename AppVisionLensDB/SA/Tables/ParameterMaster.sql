CREATE TABLE [SA].[ParameterMaster] (
    [ParameterId]    BIGINT        IDENTITY (1, 1) NOT NULL,
    [ParameterName]  VARCHAR (100) NOT NULL,
    [Incident]       TINYINT       NOT NULL,
    [Information]    TINYINT       NOT NULL,
    [Infrastructure] TINYINT       NOT NULL,
    CONSTRAINT [PK_ParameterMaster] PRIMARY KEY CLUSTERED ([ParameterId] ASC)
);

