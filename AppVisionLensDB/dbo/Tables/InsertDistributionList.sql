CREATE TABLE [dbo].[InsertDistributionList] (
    [ID]           BIGINT       IDENTITY (1, 1) NOT NULL,
    [AssociateId]  VARCHAR (10) NULL,
    [CreatedBy]    INT          NULL,
    [CreatedDate]  DATETIME     NULL,
    [ModifiedBy]   INT          NULL,
    [ModifiedDate] DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

