CREATE TABLE [MAS].[ML_Rating] (
    [RatingId]     SMALLINT      IDENTITY (1, 1) NOT NULL,
    [RatingDesc]   NVARCHAR (50) NOT NULL,
    [RatingKey]    NVARCHAR (6)  NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    [ModifiedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([RatingId] ASC)
);

