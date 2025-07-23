CREATE TABLE [dbo].[DataDictionaryTemp] (
    [ID]                     INT            IDENTITY (1, 1) NOT NULL,
    [ApplicationName]        NVARCHAR (100) NULL,
    [CauseCode]              NVARCHAR (50)  NULL,
    [ResolutionCode]         NVARCHAR (50)  NULL,
    [DebtCategory]           NVARCHAR (50)  NULL,
    [AvoidableFlag]          NVARCHAR (50)  NULL,
    [ResidualFlag]           NVARCHAR (50)  NULL,
    [ReasonForResidual]      NVARCHAR (50)  NULL,
    [ExpectedCompletionDate] DATETIME       NULL,
    [ProjectID]              BIGINT         NOT NULL,
    [ApplicationID]          BIGINT         NULL,
    [EmployeeID]             NVARCHAR (50)  NULL,
    CONSTRAINT [PK_DataDictionaryTemp] PRIMARY KEY CLUSTERED ([ID] ASC)
);

