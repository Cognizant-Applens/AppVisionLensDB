CREATE TABLE [dbo].[Internal_Users] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [Employee_ID]  CHAR (11)     NOT NULL,
    [Team]         NVARCHAR (50) NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    CONSTRAINT [PK_ID] PRIMARY KEY CLUSTERED ([ID] ASC)
);

