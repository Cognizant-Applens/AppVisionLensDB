CREATE TABLE [AVL].[MAS_TimeZoneMaster] (
    [TimeZoneID]              INT            NOT NULL,
    [TimeZoneName]            NVARCHAR (100) NULL,
    [HourDifference]          NVARCHAR (6)   NULL,
    [IsDaylightSaving]        BIT            NULL,
    [IsDeleted]               BIT            NULL,
    [CreatedBy]               NVARCHAR (50)  NULL,
    [CreatedDate]             DATETIME       NULL,
    [ModifiedBy]              NVARCHAR (50)  NULL,
    [ModifiedDate]            DATETIME       NULL,
    [TZoneName]               NVARCHAR (500) NULL,
    [UTCTimeDifferenceInMins] INT            NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_TimeZone_timezoneid]
    ON [AVL].[MAS_TimeZoneMaster]([TimeZoneID] ASC)
    INCLUDE([TimeZoneName]);

