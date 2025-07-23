CREATE TABLE [MS].[MAP_ProjectStage_Mapping] (
    [ID]                            BIGINT          IDENTITY (1, 1) NOT NULL,
    [UniqueName]                    NVARCHAR (2000) NULL,
    [ESAProjectID]                  NVARCHAR (50)   NOT NULL,
    [ProjectID]                     INT             NOT NULL,
    [ServiceMetricBasemeasureMapID] BIGINT          NULL,
    [M_PRIORITYID]                  INT             NULL,
    [M_SUPPORTCATEGORY]             INT             NULL,
    [M_TECHNOLOGY]                  NVARCHAR (10)   NULL,
    [IsDeleted]                     BIT             NULL,
    [TillDate]                      DATETIME        NULL,
    [flag]                          INT             NULL,
    CONSTRAINT [PK_ProjectStage_Mapping] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 70)
);

