CREATE TABLE [ADM].[MAS_MandateApplicability] (
    [MandateId]    SMALLINT      IDENTITY (1, 1) NOT NULL,
    [MandateName]  VARCHAR (50)  NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    CONSTRAINT [PK__MAS_Mand__A5A5EC6529FE236D] PRIMARY KEY CLUSTERED ([MandateId] ASC)
);

