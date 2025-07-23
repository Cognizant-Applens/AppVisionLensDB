CREATE TABLE [ADM].[CognizantHolidayDetails] (
    [Id]               BIGINT          IDENTITY (1, 1) NOT NULL,
    [HolidaySchedule]  VARCHAR (6)     NOT NULL,
    [Holiday]          DATE            NOT NULL,
    [Description]      VARCHAR (500)   NULL,
    [HolidayHrsNumber] DECIMAL (10, 2) NULL,
    [HolidayType]      CHAR (10)       NULL,
    [Location]         CHAR (10)       NOT NULL,
    [City]             CHAR (30)       NULL,
    [IsDeleted]        BIT             NOT NULL,
    [CreatedBy]        NVARCHAR (50)   NOT NULL,
    [CreatedDate]      DATETIME        NOT NULL,
    [ModifiedBy]       NVARCHAR (50)   NULL,
    [ModifiedDate]     DATETIME        NULL
);

