CREATE TABLE [AVL].[Map_TimeZone_Location] (
    [TimeZone_Location_Map_ID] INT           IDENTITY (1, 1) NOT NULL,
    [TimeZoneID]               INT           NULL,
    [City]                     NVARCHAR (50) NULL,
    [Country]                  NVARCHAR (5)  NULL,
    [IsDeleted]                BIT           NULL,
    CONSTRAINT [PK_Map_TimeZone_Location] PRIMARY KEY CLUSTERED ([TimeZone_Location_Map_ID] ASC)
);

