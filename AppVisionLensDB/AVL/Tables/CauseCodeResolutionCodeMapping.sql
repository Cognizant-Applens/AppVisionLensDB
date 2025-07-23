CREATE TABLE [AVL].[CauseCodeResolutionCodeMapping] (
    [CauseCodeResolutionCodeMapID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]                    BIGINT        NOT NULL,
    [CauseCodeMapID]               BIGINT        NOT NULL,
    [ResolutionCodeMapID]          BIGINT        NOT NULL,
    [Source]                       NVARCHAR (50) NULL,
    [IsDeleted]                    BIT           NULL,
    [CreatedBy]                    NVARCHAR (50) NULL,
    [CreatedDate]                  DATETIME      NULL,
    [ModifiedBy]                   NVARCHAR (50) NULL,
    [ModifiedDate]                 DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([CauseCodeResolutionCodeMapID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NC_CauseCodeMap_Project_MAPID]
    ON [AVL].[CauseCodeResolutionCodeMapping]([ProjectID] ASC, [CauseCodeMapID] ASC, [IsDeleted] ASC);

