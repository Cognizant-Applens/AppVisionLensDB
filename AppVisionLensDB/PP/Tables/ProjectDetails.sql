CREATE TABLE [PP].[ProjectDetails] (
    [ID]                      BIGINT         IDENTITY (1, 1) NOT NULL,
    [ProjectID]               BIGINT         NOT NULL,
    [ProjectShortDescription] NVARCHAR (500) NULL,
    [ProjectCategoryID]       INT            NULL,
    [IsDeleted]               BIT            NOT NULL,
    [CreatedBY]               NVARCHAR (50)  NOT NULL,
    [CreatedDate]             DATETIME       NOT NULL,
    [ModifiedBY]              NVARCHAR (50)  NULL,
    [ModifiedDate]            DATETIME       NULL,
    [IsMainSpring]            BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__ProjectD__3214EC27D25C77CE] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK__ProjectDe__Proje__4171D534] FOREIGN KEY ([ProjectCategoryID]) REFERENCES [MAS].[PPAttributeValues] ([AttributeValueID])
);

