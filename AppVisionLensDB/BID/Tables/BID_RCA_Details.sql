CREATE TABLE [BID].[BID_RCA_Details] (
    [ID]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [DealScope]    VARCHAR (50)  NOT NULL,
    [DumpName]     VARCHAR (50)  NOT NULL,
    [Root_Cause1]  VARCHAR (50)  NULL,
    [Resolution1]  TEXT          NULL,
    [Root_Cause2]  VARCHAR (50)  NULL,
    [Resolution2]  TEXT          NULL,
    [Root_Cause3]  VARCHAR (50)  NULL,
    [Resolution3]  TEXT          NULL,
    [IsDeleted]    BIT           NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [CreatedBy]    NVARCHAR (50) NOT NULL,
    [ModifiedDate] DATETIME      NULL,
    [ModifiedBy]   NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

