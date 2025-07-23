CREATE TABLE [AVL].[ITSM_PRJ_SSISColumnMapping] (
    [SSIScmID]          INT            IDENTITY (1, 1) NOT NULL,
    [ProjectID]         INT            NOT NULL,
    [ServiceDartColumn] NVARCHAR (200) NULL,
    [ProjectColumn]     NVARCHAR (200) NULL,
    [IsDeleted]         BIT            NULL,
    [CreatedDateTime]   DATETIME       NULL,
    [CreatedBY]         NVARCHAR (50)  NULL,
    [ModifiedDateTime]  DATETIME       NULL,
    [ModifiedBY]        NVARCHAR (50)  NULL,
    [SOURCEINDEX]       INT            NULL,
    [DESTINATIONINDEX]  INT            NULL,
    PRIMARY KEY CLUSTERED ([SSIScmID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NIXK1_ITSM_PRJ_SSISColumnMapping_ProjectID]
    ON [AVL].[ITSM_PRJ_SSISColumnMapping]([ProjectID] ASC);


GO
CREATE NONCLUSTERED INDEX [Idx_ProjectID_ServiceDartCol_IsDeleted]
    ON [AVL].[ITSM_PRJ_SSISColumnMapping]([ProjectID] ASC, [ServiceDartColumn] ASC, [IsDeleted] ASC);


GO
CREATE NONCLUSTERED INDEX [NIXK1_ITSM_PRJ_SSISColumnMapping_ProjectID_IsDeleted]
    ON [AVL].[ITSM_PRJ_SSISColumnMapping]([ProjectID] ASC, [IsDeleted] ASC)
    INCLUDE([ProjectColumn], [ServiceDartColumn]);

