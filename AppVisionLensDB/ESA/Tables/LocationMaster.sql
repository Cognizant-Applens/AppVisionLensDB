CREATE TABLE [ESA].[LocationMaster] (
    [ID]                  INT           IDENTITY (1, 1) NOT NULL,
    [Assignment_Location] NVARCHAR (12) NULL,
    [City]                NVARCHAR (50) NULL,
    [State]               NVARCHAR (6)  NULL,
    [Country]             NVARCHAR (5)  NULL
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-Adp_Project_Compliance_AVM-GetUserManagementDetailsByProjectid]
    ON [ESA].[LocationMaster]([ID] ASC)
    INCLUDE([City]);

