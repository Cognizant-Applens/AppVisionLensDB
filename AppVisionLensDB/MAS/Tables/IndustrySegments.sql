CREATE TABLE [MAS].[IndustrySegments] (
    [IndustrySegmentId]    INT           IDENTITY (1, 1) NOT NULL,
    [IndustrySegmentName]  NVARCHAR (50) NOT NULL,
    [ESAIndustrySegmentId] NVARCHAR (10) NOT NULL,
    [IsDeleted]            BIT           CONSTRAINT [DF_IndustrySegments_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]            NVARCHAR (50) NOT NULL,
    [CreatedDate]          DATETIME      NOT NULL,
    [ModifiedBy]           NVARCHAR (50) NULL,
    [ModifiedDate]         DATETIME      NULL,
    CONSTRAINT [PK_IndustrySegments] PRIMARY KEY CLUSTERED ([IndustrySegmentId] ASC),
    CONSTRAINT [UK_IndustrySegments] UNIQUE NONCLUSTERED ([ESAIndustrySegmentId] ASC)
);

