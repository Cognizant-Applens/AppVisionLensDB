CREATE TABLE [SA].[WeekMaster] (
    [WeekMasterID] INT  IDENTITY (1, 1) NOT NULL,
    [Weeknumber]   INT  NOT NULL,
    [WeekDate]     DATE NOT NULL,
    [WeekEndDate]  DATE NOT NULL,
    PRIMARY KEY CLUSTERED ([WeekMasterID] ASC)
);

