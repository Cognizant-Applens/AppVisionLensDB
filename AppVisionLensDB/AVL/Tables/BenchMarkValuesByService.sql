CREATE TABLE [AVL].[BenchMarkValuesByService] (
    [ID]                   BIGINT          IDENTITY (1, 1) NOT NULL,
    [AnalysisTrackID]      BIGINT          NOT NULL,
    [BenchMarkParameterID] INT             NOT NULL,
    [ParameterValue]       INT             NULL,
    [ServiceID]            INT             NOT NULL,
    [BenchMarkLevel]       INT             NULL,
    [BenchMarkValue]       DECIMAL (18, 2) NULL,
    [IsDeleted]            BIT             NOT NULL,
    [CreatedBy]            NVARCHAR (50)   NOT NULL,
    [CreatedDate]          DATETIME        NOT NULL,
    [ModifiedBy]           NVARCHAR (50)   NULL,
    [ModifiedDate]         DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    FOREIGN KEY ([BenchMarkParameterID]) REFERENCES [MAS].[BenchMarkParameter] ([BenchMarkParameterID]),
    FOREIGN KEY ([ServiceID]) REFERENCES [AVL].[TK_MAS_Service] ([ServiceID])
);

