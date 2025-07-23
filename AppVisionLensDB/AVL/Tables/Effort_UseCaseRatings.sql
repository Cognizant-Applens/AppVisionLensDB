CREATE TABLE [AVL].[Effort_UseCaseRatings] (
    [UseCaseRatingID] BIGINT         IDENTITY (1, 1) NOT NULL,
    [EmployeeID]      NVARCHAR (50)  NULL,
    [HealingTicketID] NVARCHAR (100) NULL,
    [Rating]          INT            NULL,
    [UseCaseDetailID] INT            NULL,
    [IsDeleted]       BIT            NULL,
    [CreatedBy]       NVARCHAR (50)  NULL,
    [CreatedOn]       DATETIME       NULL,
    [ModifiedBy]      NVARCHAR (50)  NULL,
    [ModifiedOn]      DATETIME       NULL,
    CONSTRAINT [PK_Effort_EmployeeUseCaseRating] PRIMARY KEY CLUSTERED ([UseCaseRatingID] ASC)
);

