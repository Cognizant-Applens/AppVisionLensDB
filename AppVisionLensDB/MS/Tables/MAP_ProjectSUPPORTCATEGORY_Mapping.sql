CREATE TABLE [MS].[MAP_ProjectSUPPORTCATEGORY_Mapping] (
    [MainSpringProjectSUPPORTCATEGORYID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ESAProjectID]                       NVARCHAR (50) NULL,
    [SUPPORTCATEGORYID]                  INT           NULL,
    [IsDeleted]                          INT           NULL,
    CONSTRAINT [PK_MainspringProjectSUPPORTCATEGORY_Mapping] PRIMARY KEY CLUSTERED ([MainSpringProjectSUPPORTCATEGORYID] ASC) WITH (FILLFACTOR = 70)
);

