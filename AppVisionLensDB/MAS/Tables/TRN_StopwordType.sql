CREATE TABLE [MAS].[TRN_StopwordType] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [StopWordKey]  NVARCHAR (10) NOT NULL,
    [StopWordDesc] NVARCHAR (25) NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [CreatedDate]  NVARCHAR (50) NOT NULL,
    [IsDeleted]    BIT           NOT NULL,
    CONSTRAINT [PK__TRN_Stop__3214EC2728C61E32] PRIMARY KEY CLUSTERED ([ID] ASC)
);

