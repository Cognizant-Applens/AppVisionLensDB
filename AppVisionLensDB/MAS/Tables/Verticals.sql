CREATE TABLE [MAS].[Verticals] (
    [VerticalID]        INT            IDENTITY (1, 1) NOT NULL,
    [VerticalName]      NVARCHAR (100) NOT NULL,
    [ESAVerticalID]     NVARCHAR (20)  NOT NULL,
    [IsDeleted]         BIT            CONSTRAINT [DF__Verticals__IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]         NVARCHAR (50)  NOT NULL,
    [CreatedDate]       DATETIME       NOT NULL,
    [ModifiedBy]        NVARCHAR (50)  NULL,
    [ModifiedDate]      DATETIME       NULL,
    [LOBID]             NVARCHAR (50)  NULL,
    [IndustrySegmentId] INT            NOT NULL,
    CONSTRAINT [PK__Verticals] PRIMARY KEY CLUSTERED ([VerticalID] ASC),
    CONSTRAINT [FK_Verticals_IndustrySegments] FOREIGN KEY ([IndustrySegmentId]) REFERENCES [MAS].[IndustrySegments] ([IndustrySegmentId]),
    CONSTRAINT [UQ__Vertical_ESAVerticalId] UNIQUE NONCLUSTERED ([ESAVerticalID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_Verticals]
    ON [MAS].[Verticals]([IsDeleted] ASC)
    INCLUDE([VerticalName]);

