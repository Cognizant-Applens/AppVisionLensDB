CREATE TABLE [AVL].[ITSM_PRJ_SSISExcelColumnMapping] (
    [SSIScmID]          INT            IDENTITY (1, 1) NOT NULL,
    [ProjectID]         INT            NOT NULL,
    [ServiceDartColumn] NVARCHAR (400) NULL,
    [ProjectColumn]     NVARCHAR (400) NULL,
    [IsDeleted]         BIT            NULL,
    [CreatedDateTime]   DATETIME       NULL,
    [CreatedBY]         NVARCHAR (50)  NULL,
    [ModifiedDateTime]  DATETIME       NULL,
    [ModifiedBY]        NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([SSIScmID] ASC)
);

