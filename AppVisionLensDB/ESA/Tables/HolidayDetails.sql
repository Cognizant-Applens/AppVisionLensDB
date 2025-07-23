CREATE TABLE [ESA].[HolidayDetails] (
    [ID]                 INT            IDENTITY (1, 1) NOT NULL,
    [LOCATION]           CHAR (10)      NULL,
    [HOLIDAY_SCHEDULE]   VARCHAR (6)    NULL,
    [HOLIDAY]            DATE           NULL,
    [DESCRIPTION]        VARCHAR (500)  NULL,
    [HOLIDAY_HRS_NUMBER] DECIMAL (9, 2) NULL,
    CONSTRAINT [PK_HolidayDetails] PRIMARY KEY CLUSTERED ([ID] ASC)
);

