CREATE TYPE [dbo].[TVP_MSOverallBaseMeasureData] AS TABLE (
    [ServiceID]                   INT           NOT NULL,
    [BaseMeasureID]               INT           NOT NULL,
    [MainspringPriorityID]        VARCHAR (25)  NULL,
    [MainspringSUPPORTCATEGORYID] VARCHAR (50)  NULL,
    [MainspringTechnology]        VARCHAR (50)  NULL,
    [BaseMeasureValue]            VARCHAR (150) NULL);

