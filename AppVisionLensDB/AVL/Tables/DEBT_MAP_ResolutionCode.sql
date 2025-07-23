CREATE TABLE [AVL].[DEBT_MAP_ResolutionCode] (
    [ResolutionID]       BIGINT         IDENTITY (1, 1) NOT NULL,
    [ResolutionCode]     NVARCHAR (500) NULL,
    [ResolutionStatusID] BIGINT         NULL,
    [ProjectID]          BIGINT         NOT NULL,
    [IsHealConsidered]   CHAR (1)       CONSTRAINT [DF_DEBT_MAP_ResolutionCode_IsHealConsidered] DEFAULT ('Y') NULL,
    [IsDeleted]          BIT            NOT NULL,
    [CreatedBy]          NVARCHAR (50)  NOT NULL,
    [CreatedDate]        DATETIME       NOT NULL,
    [ModifiedBy]         NVARCHAR (50)  NULL,
    [ModifiedDate]       DATETIME       NULL,
    [MResolutionCode]    NVARCHAR (500) NULL,
    CONSTRAINT [PK__DEBT_MAP__26CB8DFD4CA89B90] PRIMARY KEY CLUSTERED ([ResolutionID] ASC),
    CONSTRAINT [FK_DEBT_MAP_ResolutionCode_MAS_Cluster] FOREIGN KEY ([ResolutionStatusID]) REFERENCES [MAS].[Cluster] ([ClusterID]),
    CONSTRAINT [FK_DEBT_MAP_ResolutionCode_MAS_ProjectMaster] FOREIGN KEY ([ProjectID]) REFERENCES [AVL].[MAS_ProjectMaster] ([ProjectID])
);


GO
CREATE NONCLUSTERED INDEX [NC_MapRes_Project_isdeleted>]
    ON [AVL].[DEBT_MAP_ResolutionCode]([ProjectID] ASC, [IsDeleted] ASC);

