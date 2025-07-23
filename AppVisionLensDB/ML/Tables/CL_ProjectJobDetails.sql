CREATE TABLE [ML].[CL_ProjectJobDetails] (
    [ID]            BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]     BIGINT        NOT NULL,
    [JobDate]       DATETIME      NOT NULL,
    [StatusForJob]  BIT           NOT NULL,
    [CreatedBy]     NVARCHAR (50) NOT NULL,
    [CreatedDate]   DATETIME      NOT NULL,
    [IsDeleted]     BIT           NOT NULL,
    [ModifiedBy]    NVARCHAR (50) NULL,
    [ModifiedDate]  DATETIME      NULL,
    [StartDateTime] DATETIME      NULL,
    [EndDateTime]   DATETIME      NULL,
    [HasError]      INT           NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

