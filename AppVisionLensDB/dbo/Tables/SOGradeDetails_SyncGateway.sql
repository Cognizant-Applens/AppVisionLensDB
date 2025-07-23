CREATE TABLE [dbo].[SOGradeDetails_SyncGateway] (
    [SODetailsId]         BIGINT        IDENTITY (1, 1) NOT NULL,
    [RMG_RR]              VARCHAR (20)  NOT NULL,
    [JobCode]             NVARCHAR (20) NOT NULL,
    [OpenServiceOrder]    VARCHAR (20)  NOT NULL,
    [SO_Line]             INT           NOT NULL,
    [LastUpdatedDateTime] DATETIME      NULL
);

