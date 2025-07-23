CREATE TABLE [MAS].[ML_Status] (
    [StatusId]     SMALLINT      IDENTITY (1, 1) NOT NULL,
    [StatusName]   NVARCHAR (50) NOT NULL,
    [StatusKey]    NVARCHAR (6)  NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([StatusId] ASC)
);

