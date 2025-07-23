CREATE TABLE [MAS].[SubVerticals] (
    [SubVerticalID]    INT            IDENTITY (1, 1) NOT NULL,
    [SubVerticalName]  NVARCHAR (100) NOT NULL,
    [ESASubVerticalID] NVARCHAR (20)  NOT NULL,
    [VerticalID]       INT            NULL,
    [IsDeleted]        BIT            CONSTRAINT [DF__SubVertical_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]        NVARCHAR (50)  NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [ModifiedBy]       NVARCHAR (50)  NULL,
    [ModifiedDate]     DATETIME       NULL,
    CONSTRAINT [PK__SubVertical] PRIMARY KEY CLUSTERED ([SubVerticalID] ASC),
    CONSTRAINT [FK__SubVertical__Vertical] FOREIGN KEY ([VerticalID]) REFERENCES [MAS].[Verticals] ([VerticalID]),
    CONSTRAINT [UQ__SubVertical_EsaSubVerticalId] UNIQUE NONCLUSTERED ([ESASubVerticalID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_SubVerticals]
    ON [MAS].[SubVerticals]([IsDeleted] ASC)
    INCLUDE([SubVerticalName]);

