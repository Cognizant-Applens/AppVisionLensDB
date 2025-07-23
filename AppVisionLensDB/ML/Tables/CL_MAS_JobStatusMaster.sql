CREATE TABLE [ML].[CL_MAS_JobStatusMaster] (
    [JobStatusID]      INT             IDENTITY (1, 1) NOT NULL,
    [JobStatusName]    NVARCHAR (2000) NOT NULL,
    [IsDeleted]        BIT             NOT NULL,
    [JobStatusMessage] VARCHAR (4000)  NULL,
    CONSTRAINT [PK_JobStatusID] PRIMARY KEY CLUSTERED ([JobStatusID] ASC)
);

