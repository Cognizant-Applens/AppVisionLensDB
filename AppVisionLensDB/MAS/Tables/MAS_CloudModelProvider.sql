CREATE TABLE [MAS].[MAS_CloudModelProvider] (
    [CloudModelID]   INT          IDENTITY (1, 1) NOT NULL,
    [CloudModelName] VARCHAR (50) NOT NULL,
    [IsDeleted]      INT          NOT NULL,
    [CreatedDate]    DATETIME     NOT NULL,
    [CreatedBy]      BIGINT       NOT NULL,
    [ModifiedDate]   DATETIME     NULL,
    [ModifiedBy]     BIGINT       NULL,
    PRIMARY KEY CLUSTERED ([CloudModelID] ASC)
);

