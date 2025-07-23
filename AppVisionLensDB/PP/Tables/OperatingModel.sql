CREATE TABLE [PP].[OperatingModel] (
    [ID]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [ProjectID]      BIGINT        NOT NULL,
    [WorkItemSize]   SMALLINT      NULL,
    [VendorPresence] BIT           NULL,
    [CreatedBY]      NVARCHAR (50) NOT NULL,
    [CreatedDate]    DATETIME      NOT NULL,
    [ModifiedBY]     NVARCHAR (50) NULL,
    [ModifiedDate]   DATETIME      NULL,
    [IsDeleted]      BIT           NOT NULL,
    CONSTRAINT [PK_OperatingModel] PRIMARY KEY CLUSTERED ([ID] ASC)
);

