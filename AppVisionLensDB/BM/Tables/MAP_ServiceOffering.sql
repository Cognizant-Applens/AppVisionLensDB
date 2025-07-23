CREATE TABLE [BM].[MAP_ServiceOffering] (
    [offeringID]   INT          NOT NULL,
    [ServiceId]    INT          NOT NULL,
    [IsDeleted]    BIT          NOT NULL,
    [CreatedBy]    VARCHAR (80) NOT NULL,
    [CreatedDate]  DATETIME     NOT NULL,
    [ModifiedBy]   VARCHAR (80) NULL,
    [ModifiedDate] DATETIME     NULL
);

