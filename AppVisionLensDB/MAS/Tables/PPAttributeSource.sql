CREATE TABLE [MAS].[PPAttributeSource] (
    [SourceID]    SMALLINT      IDENTITY (1, 1) NOT NULL,
    [SourceName]  VARCHAR (20)  NOT NULL,
    [IsDeleted]   BIT           NOT NULL,
    [CreatedBy]   NVARCHAR (50) NOT NULL,
    [CreatedDate] DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([SourceID] ASC)
);

