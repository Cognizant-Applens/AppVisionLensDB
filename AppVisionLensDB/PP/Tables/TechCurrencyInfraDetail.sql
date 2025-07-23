CREATE TABLE [PP].[TechCurrencyInfraDetail] (
    [InfraDetailId]   INT           IDENTITY (1, 1) NOT NULL,
    [InfraDetailName] VARCHAR (100) NOT NULL,
    [IsUserDefined]   BIT           NOT NULL,
    [IsDeleted]       BIT           NOT NULL,
    [CreatedBy]       NVARCHAR (50) NOT NULL,
    [CreatedDate]     DATETIME      NOT NULL,
    [ModifiedBy]      NVARCHAR (50) NULL,
    [ModifiedDate]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([InfraDetailId] ASC)
);

