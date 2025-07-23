CREATE TABLE [MAS].[ML_LearningType] (
    [LearningTypeId]   SMALLINT      IDENTITY (1, 1) NOT NULL,
    [LearningTypeName] VARCHAR (50)  NOT NULL,
    [LearningTypeKey]  NVARCHAR (6)  NOT NULL,
    [IsDeleted]        BIT           NOT NULL,
    [CreatedBy]        NVARCHAR (50) NOT NULL,
    [CreatedDate]      DATETIME      NOT NULL,
    [ModifiedBy]       NVARCHAR (50) NULL,
    [ModifiedDate]     DATETIME      NULL,
    [isAudit]          BIT           NULL,
    PRIMARY KEY CLUSTERED ([LearningTypeId] ASC)
);

