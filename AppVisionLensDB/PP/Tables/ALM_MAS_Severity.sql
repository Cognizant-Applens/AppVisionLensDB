CREATE TABLE [PP].[ALM_MAS_Severity] (
    [SeverityId]   INT           IDENTITY (1, 1) NOT NULL,
    [SeverityName] NVARCHAR (50) NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    CONSTRAINT [PK_ALM_MAS_Severity] PRIMARY KEY CLUSTERED ([SeverityId] ASC)
);

