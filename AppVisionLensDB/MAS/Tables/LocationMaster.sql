CREATE TABLE [MAS].[LocationMaster] (
    [LocationID]   INT           IDENTITY (1, 1) NOT NULL,
    [LocationName] VARCHAR (255) NULL,
    [IsDeleted]    BIT           NULL,
    CONSTRAINT [PK_LocationMaster] PRIMARY KEY CLUSTERED ([LocationID] ASC)
);

